output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

output "aws_ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "aws_lb_listener_port_80_arn" {
  value = aws_lb_listener.alb_listener_port_80.arn
}

output "aws_lb_listener_port_443_arn" {
  value = aws_lb_listener.alb_listener_port_443.arn
}

output "aws_lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "aws_lb_zone_id" {
  value = aws_lb.main.zone_id
}

output "flask_ecs_tg" {
  value = aws_lb_target_group.flask_ecs_tg.name
}

output "flask_container_name" {
  value = var.flask_container_name
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ecs_task_definition.arn
}
