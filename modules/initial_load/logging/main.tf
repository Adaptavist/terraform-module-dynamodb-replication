data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name_prefix       = "dynamodb-copy"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}
