
resource "aws_lb" "testlb" {
  name               = "test-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.test_lb.id]
  subnets            = [aws_subnet.private_subnets.id,aws_subnet.private_subnets2.id]
  depends_on         = [ aws_autoscaling_group.testasg ]
}

resource "aws_lb_listener" "testlb-listener" {
  load_balancer_arn = aws_lb.testlb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testlb-target.arn
  }
}

resource "aws_lb_target_group" "testlb-target" {
  name     = "test-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 30
    timeout = 5
  }
}

