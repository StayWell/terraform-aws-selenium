resource "aws_ecs_task_definition" "hub" {
  family                   = "${var.id}-hub"
  container_definitions    = jsonencode(local.hub)
  execution_role_arn       = aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.hub_cpu
  memory                   = var.hub_memory
  tags                     = var.tags
}

resource "aws_ecs_service" "hub" {
  name                              = "hub"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.hub.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  health_check_grace_period_seconds = 30
  depends_on                        = [aws_lb_listener_rule.hub]
  tags                              = var.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.hub.id
    container_name   = local.hub[0].name
    container_port   = local.hub[0].portMappings[0].containerPort
  }

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = tolist(var.private_subnet_ids)
  }
}

locals {
  hub = [
    {
      name        = "this"
      image       = var.hub_image
      essential   = true
      environment = var.environment

      portMappings = [
        {
          containerPort = 4444
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.hub.name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]
}

resource "aws_lb_target_group" "hub" {
  name        = "${var.id}-hub"
  port        = local.hub[0].portMappings[0].containerPort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener_rule" "hub" {
  listener_arn = aws_lb_listener.this.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hub.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.hub.name]
    }
  }
}

resource "aws_route53_record" "hub" {
  name    = "selenium-hub.${var.domain}"
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudwatch_log_group" "hub" {
  name              = "${var.id}-hub"
  retention_in_days = var.log_retention
  tags              = var.tags
}
