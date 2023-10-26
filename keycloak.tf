# keycloak server
resource "aws_instance" "keycloak" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.app_server.id]
  subnet_id       = aws_subnet.private_subnets.id
  user_data       = file("./keycloak.sh")
  key_name        = aws_key_pair.mainkey.key_name
  tags = {
    "Name" = "keycloak"
  }
}
  