resource "aws_lb" "this" {
  name_prefix     = "${var.short_id}-"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = tolist(var.public_subnet_ids)
  tags            = var.tags

  access_logs {
    bucket  = aws_s3_bucket.this.bucket
    enabled = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  depends_on        = [aws_lb.this] # https://github.com/terraform-providers/terraform-provider-aws/issues/9976
  port              = local.hub[0].portMappings[0].containerPort
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No valid routing rule"
      status_code  = "400"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = "${var.short_id}-"
  acl           = "private"
  force_destroy = ! var.protection
  tags          = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    expiration {
      days = var.log_retention
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3.json
}

data "aws_elb_service_account" "this" {}

data "aws_iam_policy_document" "s3" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.id}-alb-"
  vpc_id      = var.vpc_id
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "alb_egress_ecs" {
  description              = "ECS"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "alb_ingress_ecs" {
  description              = "ECS"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.ecs.id
}
