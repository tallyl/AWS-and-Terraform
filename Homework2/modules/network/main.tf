resource "aws_internet_gateway" "tally-igw" {
    vpc_id = var.vpc_id

     tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-igw"}
     )

}


// do I need to fix one route table (public) associated to all public subnets ?
resource "aws_route_table" "tally-public-rt" {
    count =  length(var.public_subnets)
    vpc_id = var.vpc_id

    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        // Route Table uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.tally-igw.id}"
    }

    tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-rt-public-${count.index}"}
     )

}

resource "aws_route_table_association" "tally-rt-public-subnet"{
    count = length(var.public_subnets)
    subnet_id = var.public_subnets[count.index].id
    route_table_id = "${aws_route_table.tally-public-rt[count.index].id}"
}

# ------------------------------------
# Security Group
# ------------------------------------
resource "aws_security_group" "security_group" {
  name_prefix	= "${var.deployment_name}-sg-"
  vpc_id	    = var.vpc_id
  description	= "${var.deployment_name}-sg"

   tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-sg"}

    )
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "ingress_rule" {
  count             = length(var.sg_ingress_rules)
  type              = "ingress"
  description       = lookup(var.sg_ingress_rules[count.index], "description")
  from_port         = lookup(var.sg_ingress_rules[count.index], "from_port")
  to_port           = lookup(var.sg_ingress_rules[count.index], "to_port")
  protocol          = lookup(var.sg_ingress_rules[count.index], "protocol")
  cidr_blocks       = lookup(var.sg_ingress_rules[count.index], "cidr_blocks")
  security_group_id = aws_security_group.security_group.id
}

############################
# Private
##############################
resource "aws_eip" "nat" {
  count =  length(var.azs)

  vpc = true

   tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-nat-eip-${var.azs[count.index]}"}

    )

}

resource "aws_nat_gateway" "tally-nat-gw" {
  count =   length(var.azs)

  allocation_id = element( split(",",  join(",", aws_eip.nat.*.id), ), count.index)
  subnet_id = element(var.public_subnets.*.id,
    count.index,
  )

  tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-nat-gw-${var.azs[count.index]}"}

    )

  depends_on = [aws_internet_gateway.tally-igw]
}

resource "aws_route_table" "tally-private-rt" {
  count =  length(var.azs)

  vpc_id = var.vpc_id

   tags = merge(
      var.common_tags, {"Name" = "${var.deployment_name}-rt-private-${count.index}"}
     )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}


resource "aws_route_table_association" "tally-rt-private-subnet" {
  count =  length(var.private_subnets)

  subnet_id = element(var.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.tally-private-rt.*.id, count.index)
}

resource "aws_route" "private_nat_gateway" {
  count =  length(var.azs)

  route_table_id         = element(aws_route_table.tally-private-rt.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.tally-nat-gw.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

