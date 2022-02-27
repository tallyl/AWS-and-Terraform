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

resource "aws_subnet" "tally-subnet-public" {
  count =  length(var.public_subnets)
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  vpc_id = aws_vpc.tally-vpc.id
  // cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true" # Makes this a public subnet
  //availability_zone = "eu-west-1a"

    tags = merge(
      local.common_tags, {"Name" = "${local.deployment_name}-subnet-public-${count.index}"}

    )

}

resource "aws_subnet" "tally-subnet-private" {
  count =  length(var.private_subnets)
  cidr_block                      = element(concat(var.private_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  vpc_id = aws_vpc.tally-vpc.id
  // cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "false" # Makes this a public subnet
  //availability_zone = "eu-west-1a"

    tags = merge(
      local.common_tags, {"Name" = "${local.deployment_name}-subnet-private-${count.index}"}

    )

}

            /*
resource "aws_subnet" "tally-subnet-public-2" {
    vpc_id = aws_vpc.tally-vpc.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "true" # Makes this a public subnet
    availability_zone = "eu-west-1b"

    tags = merge(
      local.common_tags, {"Name" = "${local.deployment_name}-subnet-public-1"}

    )

}

*/
