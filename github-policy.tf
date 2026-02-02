resource "aws_iam_role_policy" "github_policy" {
  name = "github-actions-${var.github_repo}-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAuthToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${aws_ecr_repository.this.name}"
      },
      {
        Sid    = "ECSTaskDefinition"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSServiceUpdate"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
      },
      {
        Sid    = "PassRoleToECS"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ecs_task_execution.name}"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets_prefix}/*"
      }
    ]
  })
}
