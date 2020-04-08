output "lb_dns" {
  value = aws_alb.main.dns_name
}

output "execution_role_arn" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "task_role_arn" {
  value = aws_iam_role.app_role.arn
}