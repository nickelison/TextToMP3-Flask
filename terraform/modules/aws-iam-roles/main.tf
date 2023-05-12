locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

# Create an IAM policy document for the ECS task execution role.
data "aws_iam_policy_document" "ecs_task_execution_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Create an IAM role for the ECS task execution role.
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_policy.json
}

# Attach ECS task execution policy to the ECS task execution IAM role.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a custom IAM policy for accessing AWS Secrets Manager.
resource "aws_iam_policy" "secrets_manager_access_policy" {
  name        = "secrets-manager-access-policy"
  description = "Policy for accessing AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.db_creds_secret_id}"
      }
    ]
  })
}

# Attach the custom Secrets Manager access policy to the ECS task execution IAM role.
resource "aws_iam_role_policy_attachment" "secrets_manager_access_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_manager_access_policy.arn
}

resource "aws_iam_policy" "ecr_policy" {
  name        = var.ecr_policy_name
  path        = "/"
  description = "My ECR policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecs:DiscoverPollEndpoint",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_policy" {
  name        = var.ecs_policy_name
  path        = "/"
  description = "ECS policy."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeTags",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:SubmitTaskStateChange",
          "ecs:Submit*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:${local.region}:${local.account_id}:*/*",
          "arn:aws:ec2:${local.region}:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_secrets_policy" {
  name        = "ecs_task_secrets_policy"
  path        = "/"
  description = "ECS secrets policy."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:${var.db_creds_secret_id}"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ecs_cloudwatch_logs_policy"
  path        = "/"
  description = "Policy to allow ECS tasks to create and manage CloudWatch logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "ecs_load_balancing_policy" {
  name        = var.ecs_load_balancing_policy_name
  path        = "/"
  description = "ECS ELB policy."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:${local.region}:${local.account_id}:*/*",
          "arn:aws:ec2:${local.region}:${local.account_id}:*/*",
          "arn:aws:elasticloadbalancing:${local.region}:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_elb_targets_policy" {
  name        = var.ecs_elb_targets_policy_name
  path        = "/"
  description = "ECS ELB policy."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticloadbalancing:Describe*",
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:DescribeServices",
          "ecs:UpdateServicePrimaryTaskSet",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "autoscaling_policy" {
  name        = var.autoscaling_policy_name
  path        = "/"
  description = "CloudWatch policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ecs:${local.region}:${local.account_id}:*/*",
          "arn:aws:cloudwatch:${local.region}:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "dynamo_policy" {
  name        = var.dynamo_policy_name
  path        = "/"
  description = "DynamoDB policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${local.region}:${local.account_id}:*/*",
          "arn:aws:dynamodb:${local.region}:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "ecs_service_role" {
  name = var.ecs_service_role_name
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs.amazonaws.com", "ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = var.ec2_instance_role_name
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs.amazonaws.com", "ec2.amazonaws.com", "dynamodb.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role" "autoscaling_role" {
  name = var.autoscaling_role_name
  path = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["autoscaling.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cloudformation_policy" {
  name        = var.cloudformation_policy_name
  path        = "/"
  description = "CloudFormation policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeChangeSet",
          "cloudformation:GetTemplateSummary",
          "cloudformation:DescribeStackEvents",
          "cloudformation:CreateChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:UpdateStack",
          "cloudformation:ListStackResources"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:cloudformation:${local.region}:${local.account_id}:*",
          "arn:aws:cloudformation:${local.region}:${local.account_id}:transform/*"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_permissions_policy" {
  name        = var.ecr_permissions_policy_name
  path        = "/"
  description = "ECR policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:DescribeRegistry",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${local.region}:${local.account_id}:repository/*"
      },
    ]
  })
}

resource "aws_iam_policy" "session_manager_policy" {
  name        = var.session_manager_policy_name
  path        = "/"
  description = "Session Manager policy."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:DescribeAssociation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDocument",
          "ssm:DescribeDocument",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus",
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:ec2:${local.region}:${local.account_id}:*/*",
          "arn:aws:ssm:${local.region}:${local.account_id}:*/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  depends_on = [
    aws_iam_policy.ecs_load_balancing_policy,
    aws_iam_policy.ecs_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.ecs_elb_targets_policy,
    aws_iam_policy.ecs_task_secrets_policy,
    aws_iam_policy.ecs_cloudwatch_logs_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.ecs_load_balancing_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecs_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecs_elb_targets_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${aws_iam_policy.ecs_task_secrets_policy.name}",
    "arn:aws:iam::${local.account_id}:policy/${aws_iam_policy.ecs_cloudwatch_logs_policy.name}"
  ])
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  depends_on = [
    aws_iam_policy.ecr_policy,
    aws_iam_policy.dynamo_policy,
    aws_iam_policy.ecs_policy,
    aws_iam_policy.ecr_policy,
    aws_iam_policy.session_manager_policy,
    aws_iam_policy.ecs_task_secrets_policy,
    aws_iam_policy.ecs_cloudwatch_logs_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.dynamo_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecs_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.ecr_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${var.session_manager_policy_name}",
    "arn:aws:iam::${local.account_id}:policy/${aws_iam_policy.ecs_task_secrets_policy.name}",
    "arn:aws:iam::${local.account_id}:policy/${aws_iam_policy.ecs_cloudwatch_logs_policy.name}"
  ])
  role       = aws_iam_role.ec2_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "autoscaling_role_attachment" {
  depends_on = [
    aws_iam_policy.autoscaling_policy
  ]
  for_each = toset([
    "arn:aws:iam::${local.account_id}:policy/${var.autoscaling_policy_name}"
  ])
  role       = aws_iam_role.autoscaling_role.name
  policy_arn = each.value
}


resource "aws_iam_role" "lambda_role" {
  name = "example_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "example_lambda_policy"
  description = "Example policy for Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "polly:SynthesizeSpeech",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_policy" "polly_synthesize_speech_policy" {
  name        = "polly_synthesize_speech_policy"
  description = "Policy for AWS Polly SynthesizeSpeech"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "polly:SynthesizeSpeech",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "polly_policy_attachment" {
  policy_arn = aws_iam_policy.polly_synthesize_speech_policy.arn
  role       = aws_iam_role.lambda_role.name
}
