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


resource "aws_instance" "web_server" {
  count                  = var.web_instance_count
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  ebs_optimized          = true
  subnet_id              = aws_subnet.tally-subnet-public[count.index].id
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-webserver_${count.index}"}

    )

}


resource "aws_instance" "db_server" {
  count                  = var.web_instance_count
  ami           = var.ami_id
  instance_type = "t3.micro"
  ebs_optimized = true
  subnet_id              = aws_subnet.tally-subnet-private[count.index].id
  key_name               = aws_key_pair.ssh_key.key_name
  #user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [aws_security_group.security_group.id]

  tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-dbserver_${count.index}"}
    )

}

resource "aws_ebs_volume" "volume" {
  count = 2
  #availability_zone = "eu-west-1a"
  availability_zone = var.azs[count.index]
  encrypted   = true
  type = "gp2"
  size        = 10

   tags = merge(
    local.common_tags, {"Name" = "${local.deployment_name}-volume-${count.index}"}

     )
}

resource "aws_volume_attachment" "ebs_att_webserver" {
  count = 2
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.volume[count.index].id
  instance_id = aws_instance.web_server[count.index].id

}

