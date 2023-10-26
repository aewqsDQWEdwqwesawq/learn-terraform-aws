# loadbalancer
resource "aws_lb" "testlb" {
  name               = "test-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.test_lb.id]
  subnets            = [aws_subnet.public_subnets.id,aws_subnet.private_subnets2.id]
  depends_on         = [ aws_autoscaling_group.appasg ]
}

# listener for app server
resource "aws_lb_listener" "testlb-listener" {
  load_balancer_arn = aws_lb.testlb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# target group for app server
resource "aws_lb_target_group" "app" {
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
    interval = 60
    timeout = 30
  }
}


# listener for grafana server
resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.testlb.arn
  port = 3000
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

# target group for grafana
resource "aws_lb_target_group" "grafana" {
  name = "grafana-tg"
  port = 3000
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main_vpc.id
}

# grafana target group associate
resource "aws_lb_target_group_attachment" "grafana" {
  target_group_arn = aws_lb_target_group.grafana.arn
  target_id = aws_instance.grafana.id
  port = 3000
  
}

# listener for keycloak
resource "aws_lb_listener" "keycloak" {
  load_balancer_arn = aws_lb.testlb.arn
  port = 8080
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.keycloak.arn
  }
}

# target group for keycloak
resource "aws_lb_target_group" "keycloak" {
  name = "keycloak-tg"
  port = 8080
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main_vpc.id
}

# keycloak target group associate
resource "aws_lb_target_group_attachment" "keycloak" {
  target_group_arn = aws_lb_target_group.keycloak.arn
  target_id = aws_instance.keycloak.id
  port = 8080
  
}