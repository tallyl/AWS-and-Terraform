output "nlb_access_ip" {
  value       = aws_lb.public_load_balancer[0].dns_name
}

output "alb_sg" {
  value = aws_security_group.alb_sg[0].id
}