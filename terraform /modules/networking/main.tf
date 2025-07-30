# main.tf for networking module

# ---------------------------------------------------
# VPC (Virtual Private Cloud)
# ---------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Internet Gateway (for public subnet access to internet)
# ---------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Public Subnet
# ---------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a" # Using 'a' for simplicity, consider multiple AZs for production
  map_public_ip_on_launch = true # Instances in this subnet get public IPs

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Elastic IP for NAT Gateway
# ---------------------------------------------------
resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_internet_gateway.main] # Ensure IGW exists before NAT GW

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# NAT Gateway (for private subnet access to internet)
# ---------------------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public.id # NAT Gateway must be in a public subnet

  tags = {
    Name        = "${var.project_name}-nat-gateway"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Private Subnet
# ---------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a" # Using 'a' for simplicity, consider multiple AZs for production

  tags = {
    Name        = "${var.project_name}-private-subnet"
    Environment = var.environment
  }
}

# ---------------------------------------------------
# Route Table for Public Subnet
# ---------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"        # Default route for all outbound traffic
    gateway_id = aws_internet_gateway.main.id # Route through Internet Gateway
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------
# Route Table for Private Subnet
# ---------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"        # Default route for all outbound traffic
    nat_gateway_id = aws_nat_gateway.main.id # Route through NAT Gateway
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
