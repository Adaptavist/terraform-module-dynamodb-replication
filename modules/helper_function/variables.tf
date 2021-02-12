variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
}

variable "namespace" {
  type        = string
  description = "Namespace this resources belong to"
}

variable "stage" {
  type        = string
  description = "Deployment stage"
}

variable "ssm_workflow_status_parameter_arn" {
  type        = string
  description = "SSM parameter that will be managed by this function"
}

variable "target_dynamodb_table_name" {
  type        = string
  description = "Target DynamoDB Table name"
}

variable "target_region" {
  type        = string
  description = "The region for the target DynamoDB table"
}

variable "target_account" {
  type        = string
  description = "Target AWS Account Number"
}

variable "ongoing_replication_lambda_arn" {
  type        = string
  description = "Ongoing replication lambda ARN"
}

variable "ongoing_replication_lambda_name" {
  type        = string
  description = "Ongoing replication lambda name"
}

variable "ssm_param_name_source_mapping_uuid" {
  type        = string
  description = "Name of the SSM parameter holding source mapping uuid"
}

variable "ssm_param_name_source_workflow_status" {
  type        = string
  description = "Name of the SSM parameter holding the workflow status"
}