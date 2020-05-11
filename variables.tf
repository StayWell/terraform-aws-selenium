variable "subnet_ids" {
  description = "(Required) IDs of the subnets to which the services and load balancer will be deployed"
}

variable "domain" {
  description = "(Required) Domain where selenium will be hosted. Example: selenium.mycompany.com"
}

variable "zone_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id"
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

variable "hub_cpu" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "1024"
}

variable "hub_memory" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "2048" # must be in integer format to maintain idempotency
}

variable "node_cpu" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "256"
}

variable "node_memory" {
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

variable "environment" {
  description = "(Optional) Additional container environment variables"
  default     = []
}
