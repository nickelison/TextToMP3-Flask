variable "public_subnet_1_id" {
  description = "Public Subnet 1"
  type        = string
}

variable "ecs_sg_id" {
  description = "ECS security group"
  type        = string
}

variable "key_pair_name" {
  description = "..."
  type        = string
  default     = "AWSTest"
}
