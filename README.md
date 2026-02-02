# AWS ECS Infrastructure

Terraform configuration for deploying ECS Fargate infrastructure with GitHub Actions OIDC integration.

## Architecture

- **VPC**: Custom VPC with public/private subnets across 2 AZs
- **ECS Fargate**: Serverless container orchestration
- **ALB**: Application Load Balancer for traffic distribution
- **ECR**: Container registry for Docker images
- **OIDC**: GitHub Actions authentication (keyless)
- **Auto-scaling**: CPU/Memory based (1-4 tasks)

## Resources Created

- VPC with public/private subnets (us-east-1a, us-east-1b)
- Internet Gateway & NAT Gateway
- Application Load Balancer
- ECS Cluster & Service
- ECR Repository
- IAM roles (ECS execution, GitHub Actions OIDC)
- CloudWatch Log Groups
- S3 bucket for ALB logs

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- AWS Account: 975050061334
- Region: us-east-1

## Usage

### Initialize
```bash
terraform init
```

### Plan
```bash
terraform plan
```

### Apply
```bash
terraform apply
```

### Destroy
```bash
terraform destroy
```

## Configuration

Key variables in `variables.tf`:
- `project_name`: nginx-fargate-demo
- `aws_region`: us-east-1
- `github_org`: shivajichaprana
- `github_repo`: nginx-platform
- `ecs_desired_count`: 1
- `ecs_min_capacity`: 1
- `ecs_max_capacity`: 4

## Outputs

After apply, get important values:
```bash
terraform output alb_dns_name
terraform output ecr_repository_url
terraform output github_actions_role_arn
```

## Security

- VPC Flow Logs enabled
- Private subnets for ECS tasks
- Security groups with least privilege
- OIDC authentication (no stored credentials)
- S3 bucket encryption and versioning
- CloudWatch logging

## State Management

**Important**: `terraform.tfstate` contains sensitive data and should:
- Never be committed to Git
- Be stored in S3 backend (recommended for production)
- Have versioning enabled
- Be encrypted at rest

### Recommended: S3 Backend
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "ecs-infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## File Structure

```
infrastructure/
├── provider.tf          # AWS provider configuration
├── versions.tf          # Terraform version constraints
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── vpc.tf              # VPC, subnets, routing
├── alb.tf              # Application Load Balancer
├── ecs.tf              # ECS cluster, service, tasks
├── ecr.tf              # Container registry
├── iam.tf              # ECS task execution role
├── oidc.tf             # GitHub OIDC provider
├── github-role.tf      # GitHub Actions IAM role
└── github-policy.tf    # GitHub Actions permissions
```

## Cost Estimate

Approximate monthly costs (us-east-1):
- NAT Gateway: ~$32
- ALB: ~$16
- ECS Fargate (1 task): ~$15
- S3, CloudWatch, ECR: ~$5
- **Total**: ~$68/month

## Maintenance

- Review security groups quarterly
- Update Terraform provider versions
- Monitor CloudWatch logs
- Review IAM permissions
- Check for AWS service updates
