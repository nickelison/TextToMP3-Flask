variable "rds_sg_name" {
  description = "RDS security group name"
  type        = string
  default     = "rds-sg"
}

variable "ecs_sg_id" {
  description = "ECS security group ID"
  type        = string
}

variable "vpc_id" {
  description = "ECS Cluster Name"
  type        = string
}

variable "rds_port" {
  description = "TCP/IP port for application connections"
  type        = string
  default     = "5432"
}

variable "private_subnet_3_id" {
  description = "Private Subnet 3 ID"
  type        = string
}

variable "private_subnet_4_id" {
  description = "Private Subnet 4 ID"
  type        = string
}
