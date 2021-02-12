data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_s3_bucket" "glue_code" {
  bucket_prefix = "-${var.target_dynamodb_table_name}-replication-glue-code"
  acl           = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  force_destroy = true // so that the bucket can easily be destroyed once replication is not needed any more
  tags          = var.tags
}

resource "aws_s3_bucket_object" "code" {
  bucket                 = aws_s3_bucket.glue_code.id
  key                    = "InitialLoad.py"
  source                 = "glue_job/InitialLoad.py"
  server_side_encryption = "AES256"
}

resource "aws_glue_job" "initial_load" {
  name     = "InitialLoad-${var.target_dynamodb_table_name}"
  role_arn = "arn:aws:iam::${var.target_account}:role/${var.target_role_name}"

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_code.bucket}/InitialLoad.py"
    python_version  = "3"
  }

  number_of_workers = 145
  worker_type       = "G2.X"
  glue_version      = "2.0"

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--TARGET_DYNAMODB_NAME"      = var.target_dynamodb_table_name
    "--TARGET_AWS_ACCOUNT_NUMBER" = var.target_account
    "--TARGET_ROLE_NAME"          = var.target_role_name
    "--TARGET_REGION"             = var.target_region
    "--SOURCE_DYNAMODB_NAME"      = var.source_dynamodb_table_name
    "--WORKER_TYPE"               = "G2.X"
    "--NUM_WORKERS"               = 145
  }
}

resource "aws_iam_role" "glue_job_role" {
  name               = aws_glue_job.initial_load.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "glue_job_policy" {
  policy = data.aws_iam_policy_document.glue_policy_document.json
  role   = aws_iam_role.glue_job_role.id
}

data "aws_iam_policy_document" "glue_policy_document" {
  statement {
    sid    = "CrossAccountAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.target_account}:role/${var.target_role_name}"
    ]
  }
  statement {
    sid    = "DynamoDBReadOnly"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      "arn:aws:dynamodb:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:table/${var.source_dynamodb_table_name}"
    ]
  }
  statement {
    sid    = "ListTables"
    effect = "Allow"
    actions = [
      "dynamodb:ListTables"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.glue_code.arn}/*"
    ]
  }
}