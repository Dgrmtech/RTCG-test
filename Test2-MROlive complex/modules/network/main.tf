# MODULES/Network/main.tf -- VPC and subnets configuration 
# Responsabilities: (Creates the VPC, public and private subnets. Outputs VPC ID and subnet IDs.)
# modules/network/main.tf - Network Module
# This module creates the VPC, subnets, NAT gateways, route tables, and VPC endpoints.

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true # Ensures instances get public IPs
  availability_zone       = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-public-subnet-${count.index}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.name}-private-subnet-${count.index}"
  }
}

# Default Security Group
# Allows unrestricted ingress/egress traffic for initial setup (can be restricted further).
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

# Internet Gateway
# Provides internet access for public subnets.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# Public Route Table
# Associates public subnets with a route table that routes traffic to the internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0" # Routes all internet traffic
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways
# Enable private subnets to access the internet for updates, image pulls, etc.
# Allocate Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnets)
  tags = {
    Name = "${var.name}-nat-eip-${count.index}"
  }
}

# NAT Gateway Resource
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.name}-nat-gateway-${count.index}"
  }
}



resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-private-rt-${count.index}"
  }
}

resource "aws_route" "private_route" {
  count          = length(var.private_subnets)
  route_table_id = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Endpoints
# Allow private connectivity to AWS services without using the NAT Gateway.

# Interface Endpoint for ECR
resource "aws_vpc_endpoint" "ecr" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids         = aws_subnet.private[*].id
  private_dns_enabled = true
  security_group_ids = [aws_security_group.default.id]
  tags = {
    Name = "${var.name}-ecr-endpoint"
  }
}

# Interface Endpoint for CloudWatch Logs
resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.logs"
  subnet_ids         = aws_subnet.private[*].id
  private_dns_enabled = true
  security_group_ids = [aws_security_group.default.id]
  tags = {
    Name = "${var.name}-cloudwatch-logs-endpoint"
  }
}


# Interface Endpoint for CloudWatch Metrics
resource "aws_vpc_endpoint" "cloudwatch_metrics" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.monitoring"
  subnet_ids         = aws_subnet.private[*].id
  private_dns_enabled = true
  security_group_ids = [aws_security_group.default.id]
  tags = {
    Name = "${var.name}-cloudwatch-metrics-endpoint"
  }
}

# Gateway Endpoint for S3 (No subnet_ids required)
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = aws_route_table.private[*].id
  tags = {
    Name = "${var.name}-s3-endpoint"
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "${var.name}-ecs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

