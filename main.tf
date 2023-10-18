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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvszY7ZzJJrVvmcH1L+f6mRLdX+wS1mOMG0VPUW2/Tjk5pwzLZ+UKDvt60+Hou9cYm7gKGDDruYU8S+eiZ40Z696mtrbnmXj1EMzND63WaDA7GwflUGXEaG/3uZ2nvmDsUcrYYq4VbhAmHWAJ942/Ti8KO66
CEkZ6Mueuj4AxNJ3TpoTc3sYVoqDgxSKdorHWIqdZv1uYolP8Gt166fuHnODzcVb16VoupgjoE/gGm1lF9cYUqegAtq/wZXUlFupZD735PNWX5+4/Q66Us1uTzKIEpwcPRGFECcZm54tI4dekvBxmJlpnSPJDqT54NJ7Q8d5hxnLuWqcuVbE3VXGZKBhcjQ65OTf40EnV48cJMaH++
r4xIW6zNMqe7a5BdErEl8wmfXl8YLTSq1i5uIJwulR0YhYNeFmARwa2EKvrkFCEAB1tfKnFRYPatIw1RFVs5fxDrIVlx010y8OSyox6F9LotoJqn8qCWm990QZu/5AcnB1wddyWRgiMBpENoijudU= ubuntu@ip-172-31-15-91"
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
  provisioner "file" {
    source      = "./mainkey"
    destination = "/home/ubuntu/mainkey"
  }

}

