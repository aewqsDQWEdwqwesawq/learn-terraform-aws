# sg for app server

resource "aws_security_group" "app_server" {
 name = "SgforAsg"
  ingress {
    from_port   = 2022
    to_port     = 2022
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.Bastion.private_ip}/32"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main_vpc.id
}

# sg for influxDB
resource "aws_security_group" "db" {
 name = "SgforDB"
  ingress {
    from_port   = 2022
    to_port     = 2022
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.Bastion.private_ip}/32"]
  }
  
  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/23"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main_vpc.id
}

# sg for lb
resource "aws_security_group" "test_lb" {
  name = "asg-test-lb"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.main_vpc.id
}


# security group for bastion host
resource "aws_security_group" "public_sub" {
  name  = "SGforbastion"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 2022
    to_port = 2022
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# sg for grafana
resource "aws_security_group" "grafana" {
  name  = "SGforgrafana"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port = 2022
    to_port = 2022
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.Bastion.private_ip}/32"]
  }

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
