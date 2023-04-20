variable "aws_ecr_repository_name" {
  description = "AWS ECR Repository Name"
  type        = string
  default     = "flask-demo-ecr-repo"
}

variable "aws_ecr_repository_tag_mutability" {
  description = "AWS ECR Repository Image tab mutability"
  type        = string
  default     = "MUTABLE"
}
