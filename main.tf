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
  key_name   = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "BastionHost"
  }
# scp -i mainkey.pem mainkey.pem ubuntu@bastionip:/home/ubuntu
}

output "BastionHost" {
  value = aws_instance.Bastion.public_ip
}

# grafana server

resource "aws_instance" "grafana" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.grafana.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = <<EOF
  #!/bin/bash
  sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com beta main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana -y
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable grafana-server
sudo systemctl start grafana-server
EOF
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "Grafana"
  }
  
}

# DB server
resource "aws_instance" "InfluxDB" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.db.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = file("./data-nodes.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "InfluxDB"
  }
  
}

resource "aws_instance" "keyCloak" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.app_server.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = <<EOF
  #!/bin/bash
sudo apt update
sudo apt install openjdk-11-jdk -y
wget https://github.com/keycloak/keycloak/releases/download/21.1.2/keycloak-21.1.2.tar.gz
tar -zxvf keycloak-21.1.2.tar.gz
cd keycloak-21.1.2/
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=password
sudo -E $PWD/keycloak-17.0.0/bin/kc.sh start-dev
EOF
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "keyCloak"
  }
}
  