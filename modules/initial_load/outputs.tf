output "glue_job_name" {
  value = aws_glue_job.initial_load.name
}

output "glue_job_arn" {
  value = aws_glue_job.initial_load.arn
}