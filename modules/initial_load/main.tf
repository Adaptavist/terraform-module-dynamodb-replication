module "logging" {
  source = "./logging"

  log_retention_in_days = var.log_retention_in_days
  tags                  = var.tags
}

module "service" {
  source = "./task"

  tags                   = var.tags
  cw_log_group_arn       = module.logging.cw_log_group_arn
  cw_log_group_name      = module.logging.cw_log_group_name
  cpuUnits               = var.cpuUnits
  destination_role_arn   = var.destination_role_arn
  destination_table_name = var.destination_table_name
  ecr_repo_name          = "cloud-dynamodb-copy"
  ecr_repo_account       = "074742550667"
  ecr_repo_region        = "us-west-2"
  memory                 = var.memory
  source_table_name      = var.source_table_name
}


