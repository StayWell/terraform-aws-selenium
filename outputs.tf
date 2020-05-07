output "security_group_id" {
  description = "Selenium is unauthenticated so ingress must be restricted to known networks"
  value       = aws_security_group.alb.id
}
