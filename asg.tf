
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }
}

resource "aws_launch_configuration" "applc" {
  name_prefix      = "terraform-aws-asg-"
  image_id         = data.aws_ami.ubuntu.id
  instance_type    = "t2.micro"
  user_data        = file("./user-data.sh")
  security_groups  = [aws_security_group.app_server.id]
  key_name         = aws_key_pair.mainkey.key_name 
  depends_on = [ aws_instance.InfluxDB ]
}

/*
resource "aws_launch_template" "applt" {
  name = "app-server"
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.mainkey.key_name
  user_data = file("./user-data.sh")
  vpc_security_group_ids = [aws_security_group.app_server.id]
  provisioner "remote-exec" {
    inline = [ "./user-data.sh" ]
  }     
}
*/

resource "aws_autoscaling_group" "testasg" {
  name                 = "testasg"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.applc.id
  vpc_zone_identifier  = [aws_subnet.private_subnets.id,aws_subnet.private_subnets2.id]
  health_check_type    = "ELB"
  target_group_arns = [ aws_lb_target_group.testlb-target.arn ]
  depends_on = [aws_lb_target_group.testlb-target,aws_instance.InfluxDB]
  tag {
    key                 = "Name"
    value               = "App server"
    propagate_at_launch = true
  }
}

/*
resource "aws_launch_configuration" "dblc" {
  name_prefix      = "asg-db"
  image_id         = data.aws_ami.ubuntu.id
  instance_type    = "t2.micro"
  user_data        = file("./data-nodes.sh")
  security_groups  = [aws_security_group.app_server.id]
  key_name         = aws_key_pair.mainkey.key_name
}

resource "aws_autoscaling_group" "dbasg" {
  name                 = "dbasg"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.dblc.id
  vpc_zone_identifier  = [aws_subnet.private_subnets.id,aws_subnet.private_subnets2.id]
  health_check_type    = "EC2"
  tag {
    key                 = "Name"
    value               = "InfluxDB"
    propagate_at_launch = true
  }
}
*/