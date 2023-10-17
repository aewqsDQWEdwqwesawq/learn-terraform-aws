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


resource "aws_key_pair" "pka" {
  key_name   = "pka"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxF6Do/MzS6LFg89W+k3dVcN6eQI/UAfO4bqsLfAxr3jHWA5oHojRtjfiZLqSenF1OISWda/l6Ugb5fO8oTkSzJRIZ3hGXxYDHnXuMSGpS3ZTQqgEjVxyevbDLtqJshaAdaoHvLjtAXCTln4o1vCDWS0iAvaYLoYDjZa9mSBI3+9BsGJbU9M3F38kmx0ajPOqUf3PBRA0m2+dHG4yGEVFEqdwhtZtHkmeEMTOaUAj8VT5HkHfkaI8rVibkwTq2EechyKKwL7l1nbMrEtXghp5G17dbDYrbYN7aE7zVTWl66ds5WXOF8Tc8sS4bkMWrSzbbs3w26TrWpEGX2ejOnZIF rsa-key-20231013"

  tags = {
    "Name" = "pka"
  }
}



# Bastion Host instance
resource "aws_instance" "Bastion" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.public_sub.id]
  subnet_id = aws_subnet.public_subnets.id
#  key_name = aws_key_pair.pka.key_name
  
  tags = {
    "Name" = "BastionHost"
  }

}

