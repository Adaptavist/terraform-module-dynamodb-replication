variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
}

variable "helper_lambda_arn" {
  type        = string
  description = "Helper lambda ARN"
}

variable "helper_function_name" {
  type        = string
  description = "Helper lambda name"
}

variable "glue_job_name" {
  type        = string
  description = "Initial load glue job name"
}

variable "glue_job_arn" {
  type        = string
  description = "Initial load glue job ARN"
}

variable "target_region" {
  type        = string
  description = "The region for the target DynamoDB table"
}

variable "target_account" {
  type        = string
  description = "Target AWS Account Number"
}

variable "target_dynamodb_table_name" {
  type        = string
  description = "Target DynamoDB Table name"
}