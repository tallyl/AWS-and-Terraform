terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

 // backend "s3" {
 // bucket = "terraform-opsschol-tally"
 // key =  "aws-basics/terraform.tfstate"
 // profile = "opsschool"
  //role_arn = "arn:aws:iam::776404332921:role/traiana-terraform-iam-role"
 // region  = "eu-west-1"
 // }

 // required_version = ">= 0.14.9"
//}
   cloud {
    organization = "tally-opsschool"
    workspaces {
      name = "AWS-and-Terraform"
    }
  }




}

provider "aws" {
  //profile = var.profile
  region  = var.region
  //profile = var.profile
 //  assume_role {
 //   role_arn = "${var.aws_role_arn}"
 // }
//  default_tags {
//    tags = {
//      Owner = var.owner_tag
//      Purpose = var.purpose_tag
//    }
//  }
}


