output "webserver_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_app.webserver_id
}

output "dbserver_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_app.dbserver_id
}


output "webserver_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_app.webserver_public_ip
}

output "dbserver_private_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_app.dbserver_private_ip
}

//output "nlb_access_ip" {
//  value = module.create_alb.nlb_access_ip
//}

output "vpc_id" {
  value = module.create_vpc.vpc_id
}

//output "nlb_dns" {
//  value = module.create_alb.nlb_access_ip
//}

//output "alb_sg" {
//  value = module.create_alb.alb_sg
//}


