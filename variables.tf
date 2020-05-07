variable "private_subnet_ids" {
  description = "(Required) IDs of the subnets to which the services and database will be deployed"
}

variable "public_subnet_ids" {
  description = "(Required) IDs of the subnets to which the load balancer will be deployed"
}

variable "domain" {
  description = "(Required) Domain where metabase will be hosted. Example: metabase.mycompany.com"
}

variable "zone_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id"
}

variable "certificate_arn" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/lb_listener.html#certificate_arn"
}

variable "vpc_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/security_group.html#vpc_id"
}

variable "id" {
  description = "(Optional) Unique identifier for naming resources"
  default     = "selenium"
}

variable "short_id" {
  description = "(Optional) Short identifier for naming resources that have strict length requirements"
  default     = "sel"
}

variable "tags" {
  description = "(Optional) Tags applied to all resources"
  default     = {}
}

variable "hub_image" {
  description = "(Optional) https://hub.docker.com/r/selenium/hub"
  default     = "selenium/hub"
}

variable "firefox_image" {
  description = "(Optional) https://hub.docker.com/r/selenium/node-firefox"
  default     = "selenium/node-firefox"
}

variable "chrome_image" {
  description = "(Optional) https://hub.docker.com/r/selenium/node-chrome"
  default     = "selenium/node-chrome"
}

variable "opera_image" {
  description = "(Optional) https://hub.docker.com/r/selenium/node-opera"
  default     = "selenium/node-opera"
}

variable "cpu" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "256"
}

variable "memory" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "512" # must be in integer format to maintain idempotency
}

variable "chrome_replicas" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  default     = "1"
}

variable "firefox_replicas" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  default     = "0"
}

variable "opera_replicas" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  default     = "0"
}

variable "log_retention" {
  description = "(Optional) Retention period in days for both ALB and container logs"
  default     = "90"
}

variable "protection" {
  description = "(Optional) Protect ALB and application logs from deletion"
  default     = false
}

variable "internet_egress" {
  description = "(Optional) Grant internet access to the Metabase service"
  default     = true
}

variable "ssl_policy" {
  description = "(Optional) https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "environment" {
  description = "(Optional) Additional container environment variables"
  default     = []
}
