locals {
  initial_workflow_status = var.enabled ? "enabled" : "disabled"
}

resource "aws_ssm_parameter" "workflow_status" {
  name  = "/dynamodb_replication/${var.target_account}/${var.target_dynamodb_table_name}/workflow_status"
  type  = "String"
  value = local.initial_workflow_status
  // allow the step function to manage the value
  lifecycle {
    ignore_changes = [value]
  }
}

module "initial_load" {
  source = "modules/initial_load"

  source_dynamodb_table_name = var.source_table_name
  tags                       = var.tags
  target_account             = var.target_account
  target_dynamodb_table_name = var.target_dynamodb_table_name
  target_region              = var.target_region
  target_role_name           = var.target_role_name
}

module "ongoing_replication" {
  source = "modules/ongoing_replication"

  max_record_age_in_seconds  = -1 // this will be updated by the step function
  namespace                  = var.namespace
  source_table_stream_arn    = var.source_table_stream_arn
  stage                      = var.stage
  tags                       = var.tags
  target_account             = var.target_account
  target_dynamodb_table_name = var.target_dynamodb_table_name
  target_region              = var.target_region
  target_role_name           = var.target_role_name
}

module "helper_function" {
  source = "modules/helper_function"

  namespace                             = var.namespace
  ongoing_replication_lambda_arn        = module.ongoing_replication.lambda_arn
  ongoing_replication_lambda_name       = module.ongoing_replication.lambda_name
  ssm_param_name_source_mapping_uuid    = module.ongoing_replication.ssm_event_source_mapping_uuid
  ssm_param_name_source_workflow_status = aws_ssm_parameter.workflow_status.name
  ssm_workflow_status_parameter_arn     = aws_ssm_parameter.workflow_status.arn
  stage                                 = var.stage
  tags                                  = var.tags
  target_account                        = var.target_account
  target_dynamodb_table_name            = var.target_dynamodb_table_name
  target_region                         = var.target_region
}

module "orchestration" {
  source = "modules/orchestration"

  glue_job_name        = module.initial_load.glue_job_name
  helper_function_name = module.helper_function.function_name
  helper_lambda_arn    = module.helper_function.function_arn
  tags                 = var.tags
}
