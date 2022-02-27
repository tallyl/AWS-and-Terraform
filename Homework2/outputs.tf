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

output "nlb_access_ip" {
  value       = aws_lb.public_load_balancer.dns_name
}



//output "locals" {
//  value = length(var.forwarding_config)
//}



//output "num_server" {
//  value = length(aws_instance.web_server)
//}

//output "tg" {
//  value = aws_lb_target_group.tg
//}
