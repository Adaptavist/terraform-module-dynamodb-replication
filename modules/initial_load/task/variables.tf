variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
}

variable "source_table_name" {
  type        = string
  description = "Source table name"
}

variable "destination_table_name" {
  type        = string
  description = "Destination table name"
}

variable "destination_role_arn" {
  type        = string
  description = "Destination role arn that will be assumed when writing into destination table"
}

variable "cpuUnits" {
  type        = number
  description = "Fargate task definition CPU"
}

variable "memory" {
  type        = number
  description = "Fargate task definition memory"
}

variable "cw_log_group_name" {
  type        = string
  description = "Cloudwatch log group name"
}

variable "cw_log_group_arn" {
  type        = string
  description = "Cloudwatch log group ARN"
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
}

variable "ecr_repo_account" {
  type        = string
  description = "AWS Account where ECR repository is located"
}

variable "ecr_repo_region" {
  type        = string
  description = "AWS Account region where ECR repository is located"
}
