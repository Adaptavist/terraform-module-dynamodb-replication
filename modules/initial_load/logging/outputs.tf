output "cw_log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "cw_log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}

