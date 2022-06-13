locals{
  dev = "${var.env == "dev" ? "arn:aws:acm:us-east-1:336990213410:certificate/3da0109f-6da2-4f6a-a5c8-fccef7c3e09b" : ""}"
  qa = "${var.env == "qa" ? "arn:aws:acm:us-east-1:336990213410:certificate/8952549e-cd55-47e9-b636-e9c76f1610e9" : ""}"
  uat = "${var.env == "uat" ? "arn:aws:acm:us-east-1:711237182968:certificate/578d8f8e-6445-4574-ae6e-8c0f3bd8ef91" : ""}"
  prod = "${var.env == "prod" ? "arn:aws:acm:us-east-1:711237182968:certificate/6b2a5e83-f9ee-4e4e-9767-2bbdc9d16324" : ""}"
  acm = "${coalesce(local.dev, local.qa, local.uat, local.prod)}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "ldi-${var.env}-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "ldi-${var.env}-app-task-log"
}

resource "aws_ecs_task_definition" "task" {
  family = "ldi-${var.env}-app-task"
  requires_compatibilities = ["FARGATE","EC2"]
  network_mode = "awsvpc"
  cpu       = 1024
  memory    = 6144
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = <<DEFINITION
  [
    {
      "name": "ldi-${var.env}-app-task",
      "image": "${tostring(var.imageuri)}",
      "entryPoint": [],
      "environment": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.logs.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 5001,
          "hostPort": 5001
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_lb" "main" {
  name               = "ldi-${var.env}-app-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [var.subnet1, var.subnet2]
 
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name        = "ldi-${var.env}-tg-app-${substr(uuid(), 0, 3)}"
  port        = 5001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.vpcid}"
  health_check {    
    healthy_threshold   = 2
    unhealthy_threshold = 5    
    timeout             = 5    
    interval            = 30    
    path                = "/health"    
    port                = "5001"
    matcher = "200"  
  }
  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
 
  default_action {
   type = "redirect"
 
   redirect {
     port        = 443
     protocol    = "HTTPS"
     status_code = "HTTP_301"
   }
  }
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "*.aws3.liiaws.net"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }
 
resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
 
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = "${local.acm}"
 
  default_action {
    target_group_arn = aws_lb_target_group.main.id
    type             = "forward"
  }
}


resource "aws_ecs_service" "service" {
  name            = "ldi-${var.env}-app-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  depends_on      = [aws_alb_listener.http, aws_alb_listener.https]

  network_configuration {
   security_groups  = [aws_security_group.container.id]
   subnets          = [var.subnet1, var.subnet2]
   assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "ldi-${var.env}-app-task"
    container_port   = 5001
  }

#   lifecycle {
#    ignore_changes = [task_definition, desired_count]
#  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ldi-${var.env}-app-task-role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ldi-${var.env}-app-task-role-ecsTaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "s3-access-1" {
    statement {
        actions = [
            "s3:*",
        ]
        resources = [
            "*", 
        ]
    }
}

resource "aws_iam_policy" "s3-access-1" {
    name = "s3-access-1_ldi-${var.env}-app"
    path = "/"
    policy = data.aws_iam_policy_document.s3-access-1.json
}

resource "aws_iam_role_policy_attachment" "s3-access-1" {
    role       = aws_iam_role.iam_for_image.name
    policy_arn = aws_iam_policy.s3-access-1.arn
}

resource "aws_iam_role_policy_attachment" "s3-access-2" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = aws_iam_policy.s3-access-1.arn
}