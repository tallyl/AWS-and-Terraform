resource "aws_vpc" "tally-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"   # gives you an internal domain name
  enable_dns_hostnames = "true" # gives you an internal host name
  enable_classiclink = "false"

   tags = merge(
      local.common_tags, {"Name" = "${local.deployment_name}-vpc-opschool"}

    )

}

resource "aws_subnet" "tally-subnet-public-1" {
    vpc_id = aws_vpc.tally-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" # Makes this a public subnet
    availability_zone = "eu-west-1a"

    tags = merge(
      local.common_tags, {"Name" = "${local.deployment_name}-subnet-public-1"}

    )

}

