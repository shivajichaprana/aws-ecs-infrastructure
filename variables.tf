variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "nginx-fargate-demo"

  validation {
    condition     = length(var.project_name) <= 20
    error_message = "Project name must be 20 characters or less to avoid resource naming conflicts."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 4
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "alb_log_retention_days" {
  description = "S3 ALB log retention in days"
  type        = number
  default     = 30
}

variable "github_org" {
  description = "GitHub organization or username"
  type        = string
  default     = "shivajichaprana"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "nginx-platform"
}

variable "allowed_branches" {
  description = "List of allowed branches for GitHub Actions"
  type        = list(string)
  default     = ["main"]
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "nginx-demo"
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  type        = string
  default     = "nginx-fargate-demo-ecs-task-exec"
}

variable "secrets_prefix" {
  description = "Secrets Manager prefix for application secrets"
  type        = string
  default     = "nginx-platform"
}
