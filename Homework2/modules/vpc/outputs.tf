output "vpc_id" {
   value = aws_vpc.tally-vpc.id
}

output "vpc" {
   value = aws_vpc.tally-vpc
}


output "private_subnet" {
  value = aws_subnet.subnet-private
}

output "public_subnet" {
  value = aws_subnet.subnet-public
}
