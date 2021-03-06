resource "aws_ecs_task_definition" "firefox" {
  family                   = "${var.id}-firefox"
  container_definitions    = jsonencode(local.firefox)
  execution_role_arn       = aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.node_cpu
  memory                   = var.node_memory
  tags                     = var.tags
}

resource "aws_ecs_service" "firefox" {
  name                              = "firefox"
  cluster                           = aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.firefox.arn
  desired_count                     = var.firefox_replicas
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  tags                              = var.tags

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = tolist(var.subnet_ids)
  }
}

locals {
  firefox = [
    {
      name        = "this"
      image       = var.firefox_image
      essential   = true
      environment = concat(local.firefox_env, var.environment)

      command = [
        "/bin/bash",
        "-c",
        "export REMOTE_HOST=http://$(curl -s http://169.254.170.2/v2/metadata | jq -r '.Containers[1].Networks[0].IPv4Addresses[0]'):5555 ; /opt/bin/entry_point.sh"
      ]

      portMappings = [
        {
          containerPort = 5555
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.firefox.name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]

  firefox_env = [
    {
      name  = "HUB_HOST"
      value = aws_route53_record.this.name
    },
  ]
}

resource "aws_cloudwatch_log_group" "firefox" {
  name              = "${var.id}-firefox"
  retention_in_days = var.log_retention
  tags              = var.tags
}
