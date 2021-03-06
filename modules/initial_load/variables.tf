variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
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

variable "target_role_name" {
  type        = string
  description = "Target IAM Role name to be assumed by Lambda function and a Glue job"
}

variable "source_dynamodb_table_name" {
  type        = string
  description = "Source Dynamo DB table name"
}

variable "glue_worker_type" {
  type        = string
  description = "Glue worker type. See https://docs.aws.amazon.com/glue/latest/dg/add-job.html"
}

variable "glue_number_of_workers" {
  type        = number
  description = "Number of glue workers. See https://docs.aws.amazon.com/glue/latest/dg/add-job.html"
}