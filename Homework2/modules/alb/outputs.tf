output "nlb_access_ip" {
  value       = aws_lb.public_load_balancer.dns_name
}
