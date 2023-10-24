# grafana server
resource "aws_instance" "grafana" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.grafana.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = file("./grafana.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "Grafana"
  }
  
}
