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

variable "initial_load_cluster_name" {
  type        = string
  description = "Cluster name for the initial load task"
}

variable "initial_load_task_def" {
  type        = string
  description = "initial load task definition"
}

variable "initial_load_subnet" {
  type        = string
  description = "Subnet for the initial load task"
}

variable "initial_load_sg" {
  type        = string
  description = "Security group for the initial load task"
}