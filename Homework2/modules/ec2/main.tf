
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.deployment_name}--keypair"
  #public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRk39Xpl/oOOiadmZM2O8hhrFtjbZ8dDvOQGlblF7iTtiJJnhQdPW68tZwX1H3f+ZGn8D8Gq82dzraI5jHxEA3MFQlJ46MKf4RfVbEXK+e6eKJWeT6IxOgG7NYkSU9q8MdDqTNPqr/UkfAwIC4q91lM+Zv8P0VAN5rWu++3jmivQxiR2Vqu58aRDAtd+bb0f+Zct4CrJxUZYfXfeBE15uwTZ0V9QaiqcnzcEA7dmuSQtJxgWf5ik8bAKVxoFG7eNOM1SC2SBoA91/ohiQZBhpWdWqsMxeTLXM7fYdhaGJYubwdWSyPJbohrPOG2KWmisFgHUk+z5gUsWL/lf3VzOwIqXFwQAJ6oe6g1lxEyQ2kVjgyNN3l1Sz1+90agP2TkM9cjgwsd2GClIKgxSXpklcxaE1gCSl24j7lz7K4r7gzxzptN1EExEiemryPrIXXMnY2bjsbYeVhGHD5oCpzLOfMeFtJKP+QVbot1YvrEmbb3I4yDToHRnZvsciCS4zRkpU= tallyl@tallyl-VirtualBox"
  public_key =  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCa8AntTuIp+RvOhF11NLLZsionhLhp4EUKbBMhXlCGDX8rQHHD1PpJ2BfND1nmUW/0QYafskLTY3vKVRroa6nk3YQduCqVnAQfN6FQIZeek4TnvBSaDARa53X3W7uiI27BLBob/saR2ICj6aCMpB9IDrQ2WkZCFkimq28oruraB/M9iC/Z/fdolZzlabe5wQa946nz9BjLTbyfJr7RxsC087fGbpPO+p7HsuVyCrqzxL75+9PXCwKNVLdmhh4p958ocIeYZ0qtrx8BQlBee+IuDUcRFBx+dWQd9rgC82YZgcbNbtPnIcq7puLdAf7CU9+TMWWVPs/8GysXIb+sgKfWegym2OlLR+Mz28+m71iLXMPtHgjn+HkfiZD23R1GvUD0PLRJaDPz2eZJ5d9rgooCMnn+8mg1yCivhQ66Zj7vWu3Lcd712b5tRV0cTJmVjMcNv+vCLmh69KVi+ZB6Dix9PengxDjjRHlXAEIibcXhkJI/HaO/hcRkKBt6p1VtdmZKfzyWxl5TLRNOPF2Bl7Vt/afXLAT0LGhRuQcE+4O7QRnjlACBz3I2EZFhAn9SNFT7VWjlirR03ds/xG9cfI1ymsbl5j5w4mKs92ackdddGTXjmhVkXVPeqJiPaCzNgSyyu4LpLJ9mv2Z7KMm3Umrgki3OrD6FfnTQ7J+7CxuX6w== tally.loterman@gmail.com"

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

  root_block_device = [
        {
            volume_type = "gp2"
            volume_size = 1
            encrypted   = true
        },
    ]

  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-webserver_${count.index}"}

    )

}


resource "aws_instance" "db_server" {
  count         = var.db_instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  ebs_optimized = true
  subnet_id              = var.private_subnet_ids[count.index].id
  key_name               = aws_key_pair.ssh_key.key_name
  #user_data              = data.template_cloudinit_config.user_data.rendered
  vpc_security_group_ids = [var.web_sg]

  root_block_device = [
        {
            volume_type = "gp2"
            volume_size = 1
            encrypted   = true
        },
    ]
  tags = merge(
    var.common_tags, {"Name" = "${var.deployment_name}-dbserver_${count.index}"}
    )

}

resource "aws_ebs_volume" "web_volume" {
  count = var.web_instance_count
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

