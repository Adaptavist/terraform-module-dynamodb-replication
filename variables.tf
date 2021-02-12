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

variable "source_table_name" {
  type        = string
  description = "Source Dynamo DB table name"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
}

variable "enabled" {
  type        = bool
  default     = false
  description = "Indicates if the replication is enabled"
}

variable "namespace" {
  type        = string
  description = "Namespace this resources belong to"
}

variable "stage" {
  type        = string
  description = "Deployment stage"
}


variable "glue_worker_type" {
  type        = string
  default     = "G.2X"
  description = "Glue worker type. See https://docs.aws.amazon.com/glue/latest/dg/add-job.html"
}

variable "glue_number_of_workers" {
  type        = number
  default     = 145
  description = "Number of glue workers. See https://docs.aws.amazon.com/glue/latest/dg/add-job.html"
}