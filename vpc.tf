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

}

resource "aws_subnet" "private_subnets2" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"

  
}

# Public Subnet
resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  
}

# IG
resource "aws_internet_gateway" "testig" {
  vpc_id = aws_vpc.main_vpc.id
  
  tags = {
    "Name" = "igfornatgw"
  }
}

# EIP for NATGW
resource "aws_eip" "natip" {
  domain = "vpc"
  
}

# NAT GW
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.public_subnets.id
  
}


# route table
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testig.id
  }
  
}
resource "aws_route_table" "privatert" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }
}
