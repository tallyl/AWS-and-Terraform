

variable instance_type {}
variable "ami_id" {}

variable "public_subnet_ids" {
  description = "List of subnets"
}

variable "private_subnet_ids" {
  description = "List of subnets"
}

variable "iam_instance_profile" {}
variable "web_sg" {}


variable "deployment_name" {}



variable "web_instance_count" {}

variable "web_ebs_volume_size" {}

variable "public_subnets" {}

variable "azs" {}

variable "private_subnets" {}

variable  "common_tags"  {}

variable "bucket_name" {}
variable "acl_value" {}


/*
locals {
  deployment_name="opsschool-HW-two"

  common_tags =  {
    deployment_name   = local.deployment_name
    owner             = "Tally L"
    Purpose           = "Whiskey"
    application-name  = "Whiskey"
    operational-hours = "247"
    owner-email = "tallyl@traiana.com"
    operational_manager_exclude = "operational_manager_exclude"
  }

    # security ingress rule
  sg_ingress_rules = [
    {
      description = "Allow SSH",
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp"
      cidr_blocks = [
         "10.126.0.0/20", "172.16.0.0/16","84.229.153.195/32"
      ]
    },
    {
      description = "Allow ngnix",
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp"
      cidr_blocks = ["84.229.153.195/32","10.1.10.0/23","10.1.0.0/23"]
    },
  ]

}
*/




