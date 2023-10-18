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
  tags = {
    "Name" = "BastionHost"
  }

  connection {
    user        = "ubuntu"
    type        = "ssh"
    private_key = file("./mainkey.pem")
    timeout     = "2m"
  }
  provisioner "file" {
    source = "./mainkey.pem"
    destination = "./mainkey.pem"
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
