# S3 bucket for MLflow artifacts
resource "aws_s3_bucket" "mlflow" {
  bucket = "${var.environment}-mlflow-artifacts"
}

resource "aws_s3_bucket_versioning" "mlflow" {
  bucket = aws_s3_bucket.mlflow.id
  versioning_configuration {
    status = "Enabled"
  }
}

# RDS for MLflow backend
resource "aws_db_instance" "mlflow" {
  identifier        = "${var.environment}-mlflow-db"
  engine            = "postgres"
  engine_version    = "13.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "mlflow"
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.mlflow_db.id]
  db_subnet_group_name   = aws_db_subnet_group.mlflow.name

  skip_final_snapshot = true
}

# Security group for RDS
resource "aws_security_group" "mlflow_db" {
  name        = "${var.environment}-mlflow-db-sg"
  description = "Security group for MLflow database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.mlflow_server.id]
  }
}

# Security group for MLflow server
resource "aws_security_group" "mlflow_server" {
  name        = "${var.environment}-mlflow-server-sg"
  description = "Security group for MLflow server"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.mlflow_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ALB
resource "aws_security_group" "mlflow_alb" {
  name        = "${var.environment}-mlflow-alb-sg"
  description = "Security group for MLflow ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster for MLflow server
resource "aws_ecs_cluster" "mlflow" {
  name = "${var.environment}-mlflow-cluster"
}

# MLflow server task definition
resource "aws_ecs_task_definition" "mlflow" {
  family                   = "${var.environment}-mlflow"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 1024
  memory                  = 2048

  container_definitions = jsonencode([
    {
      name  = "mlflow"
      image = "ghcr.io/mlflow/mlflow:v2.7.1"
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          name  = "MLFLOW_S3_ENDPOINT_URL"
          value = "https://s3.${var.aws_region}.amazonaws.com"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        },
        {
          name  = "MLFLOW_S3_BUCKET_NAME"
          value = aws_s3_bucket.mlflow.id
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/mlflow"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "mlflow"
        }
      }
    }
  ])
}

# Target group for ALB
resource "aws_lb_target_group" "mlflow" {
  name        = "${var.environment}-mlflow-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }
}

# Application Load Balancer
resource "aws_lb" "mlflow" {
  name               = "${var.environment}-mlflow-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mlflow_alb.id]
  subnets           = var.public_subnet_ids
}

# ALB listener (HTTP)
resource "aws_lb_listener" "mlflow" {
  load_balancer_arn = aws_lb.mlflow.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow.arn
  }
}

# DB Subnet group
resource "aws_db_subnet_group" "mlflow" {
  name       = "${var.environment}-mlflow-db-subnet"
  subnet_ids = var.private_subnet_ids
}

# MLflow server service
resource "aws_ecs_service" "mlflow" {
  name            = "${var.environment}-mlflow"
  cluster         = aws_ecs_cluster.mlflow.id
  task_definition = aws_ecs_task_definition.mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.mlflow_server.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mlflow.arn
    container_name   = "mlflow"
    container_port   = 5000
  }
}