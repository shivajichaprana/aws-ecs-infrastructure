# GitHub OIDC Provider for GitHub Actions
# Thumbprint verified as of 2024 - verify at: https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "github-actions-oidc"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
}
