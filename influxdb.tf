module "influxdb" {
    source  = "./terraform-aws-influxdb-master"

    data_instances    = 1
    data_disk_size    = 1
    data_disk_iops    = 100
    meta_instances    = 1
    ami               = "ami-0c9c942bd7bf113a2"
    subnet_id         = "aws_subnet.private_subnets.id"
    vpc_id            = aws_vpc.main_vpc.id
    instance_type     = "t2.micro"
    security_group    = [aws_security_group.app_server.id]
}    