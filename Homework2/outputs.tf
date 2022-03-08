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

//output "aws_dbserver" {
//  value = module.ec2_app.db_server
//}

//output "aws_webserver" {
//  value = module.ec2_app.web_server
//}

output "nlb_access_ip" {
  value       = module.create_alb.nlb_access_ip
}


output "vpc_id" {
   value = module.create_vpc.vpc_id
}

//output "vpc" {
//   value = module.create_vpc
//}


//output "private_subnet" {
//  value = module.create_vpc.private_subnet
//}

//output "public_subnet" {
//  value = module.create_vpc.public_subnet
//}

output "nlb_dns" {
  value       = module.create_alb.nlb_access_ip
}

output "alb_sg"  {
  value = module.create_alb.alb_sg
}


