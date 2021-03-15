variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource"
}

variable "log_retention_in_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the service log group"
}