terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_key_pair" "mainkey" {
  key_name = "mainkey"
  public_key = file("./mainkey.pub")
  }

# Bastion Host instance
resource "aws_instance" "Bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.public_sub.id]
  subnet_id = aws_subnet.public_subnets.id
  tags = {
    "Name" = "BastionHost"
  }
}

# grafana server

resource "aws_instance" "grafana" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.grafana.id]
  subnet_id = aws_subnet.private_subnets.id
  user_data  = file("./grafana.sh")
  tags = {
    "Name" = "Grafana"
  }
}
