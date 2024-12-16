# MODULES/Network/main.tf -- VPC and subnets configuration 
# Responsabilities: (Creates the VPC, public and private subnets. Outputs VPC ID and subnet IDs.)

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-private-subnet-${count.index}"
  }
}

resource "aws_security_group" "default" {
  name_prefix = "${var.name}-default-sg"
  vpc_id      = aws_vpc.main.id
  description = "Default security group for ${var.name}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-default-sg"
  }
}


