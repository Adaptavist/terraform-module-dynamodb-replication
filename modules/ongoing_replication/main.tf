locals {
  ideal_function_name = "dynamodb-replication-${var.target_account}-${var.target_region}-${var.target_dynamodb_table_name}"
  function_name       = length(local.ideal_function_name) > 64 ? substr(local.ideal_function_name, 0, 63) : local.ideal_function_name
}


module "replication-lambda" {
  source  = "Adaptavist/aws-lambda/module"
  version = "1.8.0"

  description                        = "Lambda performing ongoing replication between ${var.source_table_stream_arn} and ${var.target_dynamodb_table_name}"
  //function_name                      = local.function_name
  function_name                      = "${local.function_name}-test"
  disable_label_function_name_prefix = true
  lambda_code_dir                    = "${path.module}/function"
  handler                            = "ReplayFromStream.lambda_handler"
  namespace                          = var.namespace
  runtime                            = "python3.8"
  timeout                            = "900"
  environment_variables = {
    TARGET_AWS_ACCOUNT_NUMBER = var.target_account
    TARGET_DYNAMODB_NAME      = var.target_dynamodb_table_name
    TARGET_ROLE_NAME          = var.target_role_name
    TARGET_REGION             = var.target_region
  }
  stage = var.stage
  tags  = var.tags
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
    resources = [
      var.source_table_stream_arn
    ]
  }
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
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvent"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name_prefix = "dynamodb_replication_${var.target_dynamodb_table_name}"
  policy      = data.aws_iam_policy_document.lambda_policy.json
  role        = module.replication-lambda.lambda_role_name
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn              = var.source_table_stream_arn
  function_name                 = module.replication-lambda.lambda_arn
  starting_position             = "TRIM_HORIZON"
  batch_size                    = 1000
  enabled                       = false
  maximum_record_age_in_seconds = var.max_record_age_in_seconds

  // allow the step function to enable event source mapping
  lifecycle {
    ignore_changes = [enabled, maximum_record_age_in_seconds]
  }
}

data "aws_ssm_parameter" "event_source_mapping_uuid" {
  name = "/dynamodb_replication/${var.target_account}/${var.target_region}/${var.target_dynamodb_table_name}/event_source_mapping_uuid"
}

/*

resource "aws_ssm_parameter" "event_source_mapping_uuid" {
  name  = "/dynamodb_replication/${var.target_account}/${var.target_region}/${var.target_dynamodb_table_name}/event_source_mapping_uuid"
  type  = "String"
  value = aws_lambda_event_source_mapping.this.uuid
}*/
