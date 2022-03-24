variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

//variable "profile" {
//  default = "opsschool"
//}

//variable "aws_role_arn" {
//  default = "role_arn = arn:aws:iam::776404332921:role/traiana-terraform-iam-role"
//}

variable instance_type {
  default ="t3.micro"
}

variable create_lb {
  default = false
}

variable "ami_id" {
  default="ami-0004558ff67e36bb8"
}

variable "web_instance_count" {
  default = "2"
}

variable "db_instance_count" {
  default = "0"
}

variable "web_ebs_volume_size" {
  default = "1"
}


variable "vpc_cidr_block" {
  default       = "10.0.0.0/16"
}

variable "region" {
  default = "us-east-1"
}



data "aws_availability_zones" "available" {
  state = "available"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

//variable "azs" {
//  description = "A list of availability zones  inside the VPC"
//  type        = list(string)
//  default     = ["us-east-1a", "us-east-1b", "eu-west-1c"]
//}

variable "private_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

// to disable nlb
variable "forwarding_config" {
  default = {}
}

//variable "forwarding_config" {
//  default = {
//      80        =   "HTTP"
//  }
//}

/*variable "forwarding_config" {
  default = {
      80        =   "TCP"
      443       =   "TCP" # and so on
  }
}*/

variable "deployment_name" {
  default = "tally-AWS-TF"
}

variable "common_tags" {
    default =  {
    deployment_name   = "var.deployment_name"
    owner             = "Tally L"
    Purpose           = "Whiskey"
    application-name  = "Whiskey"
    operational-hours = "247"
    owner-email = "tallyl@traiana.com"
    operational_manager_exclude = "operational_manager_exclude"
  }
}

# security ingress rule
variable "sg_ingress_rules" {
  description = "List of ingress rules"
  type        = list
  default     = [
    {
      description = "Allow SSH",
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp"
      cidr_blocks = [
        "10.126.0.0/20", "172.16.0.0/16", "84.229.153.195/32"
      ]
    },
    {
      description = "Allow ngnix",
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp"
      cidr_blocks = ["84.229.153.195/32", "10.1.10.0/23", "10.1.0.0/23"]
    },
  ]
}

# variables for sending nginx logs to s3 bucket :

variable "acl_value" {
    default = "private"
}


//locals {
//  deployment_name="tally-AWS-TF"

    # security ingress rule
  /*sg_ingress_rules = [
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
  ]*/

//}





