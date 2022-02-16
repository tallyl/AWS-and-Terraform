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

data "aws_subnet" "my_subnet" {
  tags = {
    Name = "traiana-sandbox-main_terraform_private_subnet_subnet2"
  }
}

resource "aws_instance" "instance_1" {
  ami           = "ami-0021db2ff3ef533ef"
  instance_type = "t3.micro"
  ebs_optimized = true
  subnet_id = data.aws_subnet.my_subnet.id

  tags = {
    Name = "opschool_server_1"
    Owner = "Tally L"
    Purpose = "Whiskey"
    operational-hours = "247"
    owner-email = "tallyl@traiana.com"
  }
}

resource "aws_ebs_volume" "volume_1" {
  availability_zone = "eu-west-1b"
  encrypted   = true
  type = "gp2"
  size        = 10

  tags = {
    Name = "volume_1"
    Server = "opschool_server_1"
    Owner = "Tally L"
    Purpose = "Whiskey"
  }
}

resource "aws_volume_attachment" "ebs_att_instance_1" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.volume_1.id
  instance_id = aws_instance.instance_1.id
}

resource "aws_instance" "instance_2" {
  ami           = "ami-0021db2ff3ef533ef"
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.my_subnet.id

  tags = {
    Name = "opschool_server_2"
    Owner = "Tally L"
    Purpose = "Whiskey"
    operational-hours = "247"
    owner-email = "tallyl@traiana.com"
  }
}



resource "aws_ebs_volume" "volume_2" {
  availability_zone = "eu-west-1b"
  encrypted   = true
  type = "gp2"
  size        = 10

   tags = {
    Name = "volume_2"
    Server = "opschool_server_2"
    Owner = "Tally L"
    Purpose = "Whiskey"
  }


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