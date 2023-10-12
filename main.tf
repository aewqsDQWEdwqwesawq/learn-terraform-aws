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

# Bastion Host instance
resource "aws_instance" "Bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = [aws_security_group.public_sub.id]
  subnet_id = aws_subnet.public_subnets.id
  
  tags = {
    "Name" = "BastionHost"
  }

}

