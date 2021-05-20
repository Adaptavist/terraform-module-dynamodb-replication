locals {
  ecr_url = "${var.ecr_repo_account}.dkr.ecr.${var.ecr_repo_region}.amazonaws.com/${var.ecr_repo_name}"
  ecr_arn = "arn:aws:ecr:${var.ecr_repo_region}:${var.ecr_repo_account}:repository/${var.ecr_repo_name}"
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_ecs_cluster" "this" {
  #checkov:skip=CKV_AWS_65:This cluster is short lived
  name               = "dynamodb-copy-${var.source_table_name}"
  capacity_providers = ["FARGATE"]
  tags               = var.tags
}


resource "aws_iam_role" "execution_role" {
  name_prefix          = "dynamodb-copy-exec"
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_document.json
  max_session_duration = 12 * 60 * 60 // 12 hours
  tags                 = var.tags
}

data "aws_iam_policy_document" "execution" {
  statement {
    sid    = "Logging"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "${var.cw_log_group_arn}:*",
      "${var.cw_log_group_arn}:log-stream:*",
      var.cw_log_group_arn,
    ] // Must match container logging config
  }

  statement {
    sid    = "CloudWatch"
    effect = "Allow"
    actions = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "ECRPull"
    effect    = "Allow"
    resources = [local.ecr_arn]

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages",
    ]
  }

  statement {
    sid       = "ECRAuth"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ecr:GetAuthorizationToken",
    ]
  }
  statement {
    sid    = "CrossAccountAssumeRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      var.destination_role_arn
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
      "arn:aws:dynamodb:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:table/${var.source_table_name}"
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
}

resource "aws_iam_role_policy" "execution" {
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution.json
}

data "aws_iam_policy_document" "assume_role_policy_document" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
