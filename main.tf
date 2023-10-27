terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

# latest ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }
}

# key
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mainkey" {
  key_name   = "mainKey"       # Create Key to AWS
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create Key.pem to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./mainkey.pem"
  }
  provisioner "local-exec" {
    command = "sudo chmod 400 ./mainkey.pem"
  }
}

# Bastion Host instance
resource "aws_instance" "Bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.public_sub.id]
  subnet_id = aws_subnet.public_subnets.id
  key_name   = aws_key_pair.mainkey.key_name
  user_data = <<EOF
#!/bin/bash
sudo sed -i 's/#Port 22/Port 2022/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
EOF
  tags = {
    "Name" = "BastionHost"
  }
}

output "BastionHost" {
  value = aws_instance.Bastion.public_ip
}
