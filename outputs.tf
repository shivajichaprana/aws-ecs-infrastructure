output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role for OIDC"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
