resource "aws_vpc" "tally-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = "true"   # gives you an internal domain name
  enable_dns_hostnames = "true" # gives you an internal host name
  enable_classiclink = "false"

   tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-vpc-opschool"}

    )

}

resource "aws_subnet" "subnet-public" {
  count =  length(var.public_subnets)
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index) // trick for count=0
  availability_zone               = element(var.azs, count.index)
  vpc_id = aws_vpc.tally-vpc.id
  map_public_ip_on_launch = "true" # Makes this a public subnet

    tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-subnet-public-${var.azs[count.index]}"}

    )

}

resource "aws_subnet" "subnet-private" {
  count =  length(var.private_subnets)
  cidr_block                      = element(concat(var.private_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  vpc_id = aws_vpc.tally-vpc.id
  map_public_ip_on_launch = "false" # Makes this a public subnet

    tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-subnet-private-${var.azs[count.index]}"}

    )

}