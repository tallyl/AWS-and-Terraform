output "webserver_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server[*].id
}

output "dbserver_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.db_server[*].id
}

output "webserver_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server[*].public_ip
}

output "dbserver_private_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.db_server[*].private_ip
}


output  "web_server" {
  value = aws_instance.web_server
}

output  "db_server" {
  value = aws_instance.db_server
}