terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${local.deployment_name}--keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRk39Xpl/oOOiadmZM2O8hhrFtjbZ8dDvOQGlblF7iTtiJJnhQdPW68tZwX1H3f+ZGn8D8Gq82dzraI5jHxEA3MFQlJ46MKf4RfVbEXK+e6eKJWeT6IxOgG7NYkSU9q8MdDqTNPqr/UkfAwIC4q91lM+Zv8P0VAN5rWu++3jmivQxiR2Vqu58aRDAtd+bb0f+Zct4CrJxUZYfXfeBE15uwTZ0V9QaiqcnzcEA7dmuSQtJxgWf5ik8bAKVxoFG7eNOM1SC2SBoA91/ohiQZBhpWdWqsMxeTLXM7fYdhaGJYubwdWSyPJbohrPOG2KWmisFgHUk+z5gUsWL/lf3VzOwIqXFwQAJ6oe6g1lxEyQ2kVjgyNN3l1Sz1+90agP2TkM9cjgwsd2GClIKgxSXpklcxaE1gCSl24j7lz7K4r7gzxzptN1EExEiemryPrIXXMnY2bjsbYeVhGHD5oCpzLOfMeFtJKP+QVbot1YvrEmbb3I4yDToHRnZvsciCS4zRkpU= tallyl@tallyl-VirtualBox"

    tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-keypair"}

    )

}


# ------------------------------------
# Template file
# ------------------------------------
data "template_file" "user_data" {
template = file("${path.module}/user_data.tpl")
vars = {
  deployment_name = local.deployment_name
}
}

# ------------------------------------
# User Data
# ------------------------------------
data "template_cloudinit_config" "user_data" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = data.template_file.user_data.rendered
  }
}


data "aws_subnet" "my_subnet" {
  tags = {
    Name = "traiana-sandbox-main_terraform_public_subnet_subnet2"
  }
}

data "aws_vpc" "vpc" {
  tags = { Name = "traiana-sandbox-main" }
}

# ------------------------------------
# Security Group
# ------------------------------------
resource "aws_security_group" "security_group" {
  name_prefix	= "${local.deployment_name}-sg-"
  vpc_id	    = data.aws_vpc.vpc.id
  description	= "${local.deployment_name}-sg"

   tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-sg"}

    )
}

resource "aws_security_group_rule" "egress_rule" {
  type              = "egress"
  description       = "Allow ANY"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "ingress_rule" {
  count             = length(local.sg_ingress_rules)
  type              = "ingress"
  description       = lookup(local.sg_ingress_rules[count.index], "description")
  from_port         = lookup(local.sg_ingress_rules[count.index], "from_port")
  to_port           = lookup(local.sg_ingress_rules[count.index], "to_port")
  protocol          = lookup(local.sg_ingress_rules[count.index], "protocol")
  cidr_blocks       = lookup(local.sg_ingress_rules[count.index], "cidr_blocks")
  security_group_id = aws_security_group.security_group.id
}



resource "aws_instance" "instance_1" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  ebs_optimized          = true
  subnet_id              = data.aws_subnet.my_subnet.id
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-server_1"}
#    tomap(
#      "Name", "${local.deployment_name}-server_1"
#    )
    )

}

resource "aws_ebs_volume" "volume_1" {
  availability_zone = "eu-west-1b"
  encrypted   = true
  type = "gp2"
  size        = 10

   tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-volume-1"}

     )
}

resource "aws_volume_attachment" "ebs_att_instance_1" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.volume_1.id
  instance_id = aws_instance.instance_1.id

}

resource "aws_instance" "instance_2" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.my_subnet.id
  key_name      = aws_key_pair.ssh_key.key_name
  user_data     = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-server_2"}
  )
}


resource "aws_ebs_volume" "volume_2" {
  availability_zone = "eu-west-1b"
  encrypted   = true
  type = "gp2"
  size        = 10

    tags = merge(
    local.common_tags, {"Name"= "${local.deployment_name}-volume2"}

  )


  /*  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }*/
}

resource "aws_volume_attachment" "ebs_att_instance_2" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.volume_2.id
  instance_id = aws_instance.instance_2.id
}