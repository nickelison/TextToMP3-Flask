terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60.0"
    }
  }
}

module "aws-network" {
  source = "./modules/aws-network"
}

module "aws-ecr" {
  source = "./modules/aws-ecr"
}

module "aws-iam-roles" {
  source = "./modules/aws-iam-roles"
}

module "aws-cloudwatch" {
  source = "./modules/aws-cloudwatch"
}

module "aws-ecs" {
  source               = "./modules/aws-ecs"
  region               = module.aws-iam-roles.region
  vpc                  = module.aws-network.vpc_id
  public_subnet_1      = module.aws-network.public_subnet_1_id
  public_subnet_2      = module.aws-network.public_subnet_2_id
  private_subnet_1     = module.aws-network.private_subnet_1_id
  private_subnet_2     = module.aws-network.private_subnet_2_id
  ecs_service_role_arn = module.aws-iam-roles.ecs_service_role_arn
  ec2_role_name        = module.aws-iam-roles.ec2_role_name
  autoscaling_role_arn = module.aws-iam-roles.autoscaling_role_arn
  ecr_repo_url         = module.aws-ecr.ecr_repo_url
  execution_role_arn   = module.aws-iam-roles.task_execution_role_arn
  ecs_log_group_name   = module.aws-cloudwatch.ecs_log_group_name
}

module "aws-ec2" {
  source             = "./modules/aws-ec2"
  public_subnet_1_id = module.aws-network.public_subnet_1_id
  ecs_sg_id          = module.aws-ecs.ecs_sg_id
}

module "aws-rds" {
  source              = "./modules/aws-rds/"
  vpc_id              = module.aws-network.vpc_id
  ecs_sg_id           = module.aws-ecs.ecs_sg_id
  private_subnet_3_id = module.aws-network.private_subnet_3_id
  private_subnet_4_id = module.aws-network.private_subnet_4_id
}

module "aws-route-53" {
  source          = "./modules/aws-route-53"
  domain_name     = "slangz.com"
  hosted_zone_id  = "Z06138032V7HTVCQSJ7RH"
  aws_lb_dns_name = module.aws-ecs.aws_lb_dns_name
  aws_lb_zone_id  = module.aws-ecs.aws_lb_zone_id
}

module "aws-s3" {
  source      = "./modules/aws-s3"
  bucket_name = "cloud-project-demo-app"
}
