variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
}

variable "source_account_number" {
  type        = string
  description = "Source account number"
}

variable "target_table_name" {
  type        = string
  description = "Target table name"
}