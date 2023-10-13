
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }
}

resource "aws_launch_configuration" "applc" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  user_data       = file("user-data.sh")
  security_groups = [aws_security_group.app_server.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "testasg" {
  name                 = "testasg"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.applc.id
  vpc_zone_identifier  = [aws_subnet.private_subnets.id,aws_subnet.private_subnets2.id]

  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "App server"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "test" {
  autoscaling_group_name = aws_autoscaling_group.testasg.id
  lb_target_group_arn   = aws_lb_target_group.testlb-target.id
}