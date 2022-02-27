variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "profile" {
  default = "opsschool"
}


variable "ami_id" {
  default="ami-0000bebe516f304b1"
}


# Example :
/* variable "AMI" {
    type = "map"

    default {
        eu-west-2 = "ami-03dea29b0216a1e03"
        us-east-1 = "ami-0c2a1acae6667e438"
    }
 }
 ami = "${lookup(var.AMI, var.AWS_REGION)}"
 */

variable "region" {
  default = "eu-west-1"
}

variable "web_instance_count" {
  default = "2"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "azs" {
  description = "A list of availability zones  inside the VPC"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}



variable "forwarding_config" {
  default = {
      80        =   "TCP"
      443       =   "TCP" # and so on
  }
}


variable "nlb_tcp_ports" {
  default = ["80", "443" ]
}

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

  /*
  instance_ports_combo = [
    # in pair, element zero is a network and element one is a subnet,
    # in all unique combinations.
    for pair in setproduct(range(length(var.forwarding_config)),range(var.web_instance_count)) : {
      target_group_arn = pair[0]
      target_id  = pair[1]

    }
  ]*/

}





