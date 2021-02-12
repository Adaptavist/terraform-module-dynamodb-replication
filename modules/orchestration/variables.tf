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