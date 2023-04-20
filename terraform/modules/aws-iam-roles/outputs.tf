output "ecs_service_role_arn" {
  value = aws_iam_role.ecs_service_role.arn
}

output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}

output "autoscaling_role_arn" {
  value = aws_iam_role.autoscaling_role.arn
}

output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
