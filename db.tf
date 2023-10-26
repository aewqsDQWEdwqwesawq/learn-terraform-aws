# DB server
resource "aws_instance" "InfluxDB1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.db.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = file("./db.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "InfluxDB"
  }
}

resource "aws_instance" "InfluxDB2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.db.id]
  subnet_id       = aws_subnet.private_subnets2.id
  user_data       = file("./db.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "InfluxDB2"
  }
}

resource "aws_instance" "InfluxDB" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.db.id]
  subnet_id       = aws_subnet.private_subnets2.id
  user_data       = file("./db.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "InfluxDB2"
  }
}
