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
variable "region" {
  default = "eu-west-1"
}

locals {
  deployment_name="opsschool_HW1"

  # security ingress rule
  sg_ingress_rules = [
    {
      description = "Allow SSH",
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp"
      cidr_blocks = [
        "10.1.0.0/23", "10.1.2.0/23", "10.1.10.0/23", "10.100.8.0/22", "10.164.0.0/16", "10.126.0.0/20",
        "10.165.0.0/18", "192.168.20.0/24", "172.16.0.0/16","84.229.153.195/32"
      ]
    },
    {
      description = "Allow SQLNet",
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp"
      cidr_blocks = [
        "10.1.0.0/23", "10.1.2.0/23", "10.1.10.0/23", "10.100.8.0/22", "10.164.0.0/16", "10.126.0.0/20",
        "10.165.0.0/18", "192.168.20.0/24", "192.168.21.0/24", "192.168.211.0/24", "172.16.0.0/16","84.229.153.195/32"
      ]
    },
  ]

  common_tags =  {
    deployment_name   = local.deployment_name
    #environment       = local.environment
    owner             = "Tally L"
    Purpose           = "Whiskey"
    application-name  = "Whiskey"
    operational-hours = "247"
    owner-email = "tallyl@traiana.com"
    operational_manager_exclude = "operational_manager_exclude"
  }

}