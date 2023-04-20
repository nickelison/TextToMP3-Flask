variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role."
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "ecr_policy_name" {
  description = "ECR policy name"
  type        = string
  default     = "ecr_policy"
}

variable "ecs_policy_name" {
  description = "ECS policy name"
  type        = string
  default     = "ecs_policy"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "flask-ecr-repo"
}

variable "ecs_service_role_name" {
  description = "ECS service role name"
  type        = string
  default     = "ecs_service_role"
}

variable "ec2_instance_role_name" {
  description = "EC2 instance role name"
  type        = string
  default     = "ec2_role"
}

variable "autoscaling_role_name" {
  description = "ASG role name"
  type        = string
  default     = "autoscaling_role"
}

variable "ecs_load_balancing_policy_name" {
  description = "ECS LoadBalancing permissions name"
  type        = string
  default     = "ecs_load_balancing_policy"
}

variable "ecs_elb_targets_policy_name" {
  description = "ECS LoadBalancing Targets permissions name"
  type        = string
  default     = "ecs_elb_targets_policy"
}

variable "dynamo_policy_name" {
  description = "DynamoDB policy name"
  type        = string
  default     = "dynamo_policy"
}

variable "autoscaling_policy_name" {
  description = "Autoscaling policy name"
  type        = string
  default     = "autoscaling_policy"
}

variable "cloudformation_policy_name" {
  description = "CloudFormation policy name"
  type        = string
  default     = "cloudformation_policy"
}

variable "ecr_permissions_policy_name" {
  description = "ECR permissions name"
  type        = string
  default     = "ecr_permissions_policy"
}

variable "iam_pass_role_policy_name" {
  description = "IAM Pass role policy name"
  type        = string
  default     = "iam_pass_role_policy"
}

variable "ssm_parameter_policy_name" {
  description = "SSM parameter policy name"
  type        = string
  default     = "ssm_parameter_policy"
}

variable "session_manager_policy_name" {
  description = "Session Manager policy name"
  type        = string
  default     = "session_manager_policy"
}
