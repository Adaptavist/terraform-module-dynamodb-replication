output "task_definition" {
  value = aws_ecs_task_definition.td.id
}

output "cluster_name" {
  value = aws_ecs_cluster.this.name
}