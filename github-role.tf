locals {
  # Generate branch conditions for GitHub OIDC
  branch_conditions = [
    for branch in var.allowed_branches :
    "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${branch}"
  ]
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions-${var.github_repo}"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = local.branch_conditions
        }
      }
    }]
  })

  tags = {
    Name        = "github-actions-${var.github_repo}"
    Repository  = "${var.github_org}/${var.github_repo}"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}
