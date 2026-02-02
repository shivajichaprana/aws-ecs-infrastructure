resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_security_group" "ecs" {
  name   = "${var.project_name}-ecs-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow traffic from ALB"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for ECR and AWS APIs"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow DNS TCP"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow DNS UDP"
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-logs"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "nginx:1.25-alpine"
      portMappings = [
        { containerPort = 80 }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "nginx"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "nginx"
    container_port   = 80
  }

  health_check_grace_period_seconds = 60

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name = "${var.project_name}-service"
  }
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = var.ecs_max_capacity
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.project_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "ecs_memory" {
  name               = "${var.project_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
  }
}
