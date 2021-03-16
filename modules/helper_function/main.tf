module "helper_lambda" {
  source  = "Adaptavist/aws-lambda/module"
  version = "1.8.0"

  description                        = "SSM helper for dynamoDB replication state machine"
  function_name                      = "helper-${var.target_account}-${var.target_region}-${var.target_dynamodb_table_name}"
  disable_label_function_name_prefix = true
  lambda_code_dir                    = "${path.module}/function"
  handler                            = "Helper.lambda_handler"
  namespace                          = var.namespace
  runtime                            = "python3.8"
  stage                              = var.stage
  tags                               = var.tags
  timeout                            = "900"
  environment_variables = {
    ONGOING_REPLICATION_FUNCTION_NAME = var.ongoing_replication_lambda_name
    SSM_EVENT_SOURCE_MAPPING_UUID     = var.ssm_param_name_source_mapping_uuid
    SSM_WORKFLOW_STATUS               = var.ssm_param_name_source_workflow_status
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:UpdateFunctionEventInvokeConfig"
    ]
    resources = [var.ongoing_replication_lambda_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:UpdateEventSourceMapping"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  name_prefix = "dynamodb_replication_helper"
  policy      = data.aws_iam_policy_document.lambda_policy.json
  role        = module.helper_lambda.lambda_role_name
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}