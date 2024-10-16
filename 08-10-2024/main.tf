terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  
    }
  }
}

provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true            
  enable_dns_hostnames = true            
  tags = {
    Name = "MyVPC"
  }
}

# Create the first subnet in the VPC
resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id  
  cidr_block        = var.subnet1_cidr

  availability_zone =  var.availability_zone1   
  map_public_ip_on_launch = true         
  tags = {
    Name = "MySubnet1"
  }
}

# Create the second subnet in a different availability zone
resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id  
  cidr_block        = var.subnet2_cidr   
  availability_zone = var.availability_zone2
  tags = {
    Name = "MySubnet2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "example_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.my_subnet_1.id
  tags = {
    Name = "example-nat-gateway"
  }
}

# Create a Public Route Table 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a Private Route Table 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example_nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_assoc" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}