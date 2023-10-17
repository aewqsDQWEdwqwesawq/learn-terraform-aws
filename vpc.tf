# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# private Subnet 
resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    "Name" = "Private1"
  }

}

resource "aws_subnet" "private_subnets2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name" = "Private2"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PublicSubnet"
  }
  
}

# IG
resource "aws_internet_gateway" "testig" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    "Name" = "ig"
  }
}

# EIP for NATGW
resource "aws_eip" "natip" {
  domain = "vpc"
}

resource "aws_eip" "natip2" {
  domain = "vpc"
}

# NAT GW
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.public_subnets.id
}

resource "aws_nat_gateway" "natgw2" {
  allocation_id = aws_eip.natip2.id
  subnet_id = aws_subnet.public_subnets2.id
}

# route table
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "publicroute" {
  route_table_id = aws_route_table.publicrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.testig.id
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "privateroute" {
  route_table_id = aws_route_table.privatert.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw.id
}

resource "aws_route_table" "privatert2" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "privateroute2" {
  route_table_id = aws_route_table.privatert2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgw2.id
}

# route table association
resource "aws_route_table_association" "publicrt" {
  subnet_id = aws_subnet.public_subnets.id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table_association" "privatert1" {
  subnet_id = aws_subnet.private_subnets.id
  route_table_id = aws_route_table.privatert.id
}

resource "aws_route_table_association" "privatert2" {
  subnet_id = aws_subnet.private_subnets2.id
  route_table_id = aws_route_table.privatert2.id
}
