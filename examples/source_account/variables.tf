variable "target_account_role_name" {
  type        = string
  description = "Target accoynt IAM role name that will be assumed by resources deployed in the source account. These resources will manage the migration"
}

variable "target_account_number" {
  type        = string
  description = "Target account number"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
}
