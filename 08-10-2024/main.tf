terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  
    }
  }
}

provider "aws" {
  region = "us-west-2"  
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"   
  enable_dns_support   = true            
  enable_dns_hostnames = true            
  tags = {
    Name = "MyVPC"
  }
}

# Create the first subnet in the VPC
resource "aws_subnet" "my_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id  
  cidr_block        = "10.0.1.0/24"      
  availability_zone = "us-west-2a"       
  map_public_ip_on_launch = true         
  tags = {
    Name = "MySubnet1"
  }
}

# Create the second subnet in a different availability zone
resource "aws_subnet" "my_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id  
  cidr_block        = "10.0.2.0/24"      
  availability_zone = "us-west-2b"               
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


