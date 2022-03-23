
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.deployment_name}--keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRk39Xpl/oOOiadmZM2O8hhrFtjbZ8dDvOQGlblF7iTtiJJnhQdPW68tZwX1H3f+ZGn8D8Gq82dzraI5jHxEA3MFQlJ46MKf4RfVbEXK+e6eKJWeT6IxOgG7NYkSU9q8MdDqTNPqr/UkfAwIC4q91lM+Zv8P0VAN5rWu++3jmivQxiR2Vqu58aRDAtd+bb0f+Zct4CrJxUZYfXfeBE15uwTZ0V9QaiqcnzcEA7dmuSQtJxgWf5ik8bAKVxoFG7eNOM1SC2SBoA91/ohiQZBhpWdWqsMxeTLXM7fYdhaGJYubwdWSyPJbohrPOG2KWmisFgHUk+z5gUsWL/lf3VzOwIqXFwQAJ6oe6g1lxEyQ2kVjgyNN3l1Sz1+90agP2TkM9cjgwsd2GClIKgxSXpklcxaE1gCSl24j7lz7K4r7gzxzptN1EExEiemryPrIXXMnY2bjsbYeVhGHD5oCpzLOfMeFtJKP+QVbot1YvrEmbb3I4yDToHRnZvsciCS4zRkpU= tallyl@tallyl-VirtualBox"

    tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-keypair"}

    )

}

resource "aws_s3_bucket" "logs_bucket" {
    bucket = lower(var.bucket_name)

  tags = merge(
    var.common_tags, {"Name" = var.bucket_name}
          )

}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.logs_bucket.id
  acl    = var.acl_value
}

# ------------------------------------
# Template file
# ------------------------------------
data "template_file" "user_data" {
template = file("${path.module}/user_data.tpl")
vars = {
  deployment_name = var.deployment_name
  bucket_name = var.bucket_name
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
  instance_type          = var.instance_type
  ebs_optimized          = true
  subnet_id              = var.public_subnet_ids[count.index].id
  key_name               = aws_key_pair.ssh_key.key_name
  user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [var.web_sg]
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile

  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-webserver_${count.index}"}

    )

}


resource "aws_instance" "db_server" {
  count                  = var.web_instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = true
  subnet_id              = var.private_subnet_ids[count.index].id
  key_name               = aws_key_pair.ssh_key.key_name
  #user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [var.web_sg]

  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-dbserver_${count.index}"}
    )

}

resource "aws_ebs_volume" "web_volume" {
  count = var.web_instance_count
  #availability_zone = "eu-west-1a"
  availability_zone = var.azs[count.index]
  encrypted   = true
  type = "gp2"
  size        = var.web_ebs_volume_size

   tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-volume-${count.index}"}

     )
}

resource "aws_volume_attachment" "ebs_att_webserver" {
  count = var.web_instance_count
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.web_volume[count.index].id
  instance_id = aws_instance.web_server[count.index].id

}

