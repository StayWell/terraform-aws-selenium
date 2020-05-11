resource "aws_ecs_task_definition" "chrome" {
  family                   = "${var.id}-chrome"
  container_definitions    = jsonencode(local.chrome)
  execution_role_arn       = aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.node_cpu
  memory                   = var.node_memory
  tags                     = var.tags
}

resource "aws_ecs_service" "chrome" {
  name                              = "chrome"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.chrome.arn
  desired_count                     = var.chrome_replicas
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  tags                              = var.tags

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = tolist(var.subnet_ids)
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
  ]
}

resource "aws_cloudwatch_log_group" "chrome" {
  name              = "${var.id}-chrome"
  retention_in_days = var.log_retention
  tags              = var.tags
}
