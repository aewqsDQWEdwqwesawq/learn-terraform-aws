# latest ubuntu ami
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }
}

# app server launch configuration + userdata
resource "aws_launch_configuration" "applc" {
  name_prefix      = "terraform-aws-asg-"
  image_id         = data.aws_ami.ubuntu.id
  instance_type    = "t2.micro"
  user_data        = <<EOF
#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo systemctl restart nginx
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
sudo apt update
sudo apt install -y telegraf
cat << EOT | sudo tee -a /etc/telegraf/telegraf.conf
[[outputs.influxdb]]
  urls = ["http://${aws_instance.InfluxDB1.private_ip}:8086"]
  database = "telegraf"
  username = "telegraf"
  password = "password"
[[outputs.influxdb]]
  urls = ["http://${aws_instance.InfluxDB2.private_ip}:8086"]
  database = "telegraf"
  username = "telegraf"
  password = "password"
EOT
sudo systemctl restart telegraf
EOF
  security_groups  = [aws_security_group.app_server.id]
  key_name         = aws_key_pair.mainkey.key_name 
}

# asg for app server
resource "aws_autoscaling_group" "testasg" {
  name                 = "testasg"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.applc.id
  vpc_zone_identifier  = [aws_subnet.private_subnets.id,aws_subnet.private_subnets2.id]
  health_check_type    = "ELB"
  target_group_arns = [ aws_lb_target_group.testlb-target.arn ]
  depends_on = [aws_lb_target_group.testlb-target,aws_instance.InfluxDB1,aws_instance.InfluxDB2]
  tag {
    key                 = "Name"
    value               = "App server"
    propagate_at_launch = true
  }
}
