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

variable "target_role_name" {
  type        = string
  description = "Target IAM Role name to be assumed by Lambda function and a Glue job"
}

variable "source_table_stream_arn" {
  type        = string
  description = "Source Dynamo DB table stream ARN"
}

variable "max_record_age_in_seconds" {
  type        = string
  description = "The maximum age (in seconds) of a record that Lambda sends to your function."
}

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