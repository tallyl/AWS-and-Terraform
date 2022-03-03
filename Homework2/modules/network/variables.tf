
variable "vpc_id" {}


variable "region" {
  default = "eu-west-1"
}


variable "public_subnets" {}

variable "azs" {}

variable "private_subnets" {}



variable "deployment_name" {
  default = "opsschool-HW-three"
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

  variable "sg_ingress_rules" {
    type = list
  }






