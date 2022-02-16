output "instance_id_1" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instance_1.id
}

output "instance_id_2" {
  description = "ID of the EC2 instance"
  value       = aws_instance.instance_2.id
}


output "instance_public_ip_1" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.instance_1.private_ip
}

output "instance_public_ip_2" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.instance_2.private_ip
}