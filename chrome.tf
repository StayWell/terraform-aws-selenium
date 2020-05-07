resource "aws_ecs_task_definition" "chrome" {
  family                   = "${var.id}-chrome"
  container_definitions    = jsonencode(local.chrome)
  execution_role_arn       = aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = var.tags
}

resource "aws_ecs_service" "chrome" {
  name                              = "chrome"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.chrome.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  health_check_grace_period_seconds = 30
  depends_on                        = [aws_lb_listener_rule.chrome]
  tags                              = var.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.chrome.id
    container_name   = local.chrome[0].name
    container_port   = local.chrome[0].portMappings[0].containerPort
  }

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = tolist(var.private_subnet_ids)
  }
}

locals {
  chrome = [
    {
      name        = "this"
      image       = var.chrome_image
      essential   = true
      environment = concat(local.chrome_env, var.environment)

      portMappings = [
        {
          containerPort = 5555
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.chrome.name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]

  chrome_env = [
    {
      name  = "HUB_HOST"
      value = aws_route53_record.hub.name
    },
    {
      name  = "HUB_PORT"
      value = tostring(aws_lb_listener.https.port)
    },
  ]
}

resource "aws_lb_target_group" "chrome" {
  name        = "${var.id}-chrome"
  port        = local.chrome[0].portMappings[0].containerPort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "chrome" {
  listener_arn = aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chrome.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.chrome.name]
    }
  }
}

resource "aws_route53_record" "chrome" {
  name    = "selenium-chrome.${var.domain}"
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudwatch_log_group" "chrome" {
  name              = "${var.id}-chrome"
  retention_in_days = var.log_retention
  tags              = var.tags
}
