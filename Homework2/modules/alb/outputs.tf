output "nlb_access_ip" {
  value       = aws_lb.public_load_balancer.dns_name
}

output "alb_sg" {
  value = aws_security_group.alb_sg[0].id
}