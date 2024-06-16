# ------------------------------------------------------------
#  VPC
# ------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.tag_name}-vpc"
  }
}
# ------------------------------------------------------------
#  Subnet
# ------------------------------------------------------------
resource "aws_subnet" "public_sub_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name}-public_sub_a"
  }
}

resource "aws_subnet" "public_sub_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.tag_name}-public_sub_c"
  }
}

resource "aws_subnet" "private_sub_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.128.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.tag_name}-private_sub_a"
  }
}

resource "aws_subnet" "private_sub_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.144.0/20"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_name}-private_sub_c"
  }
}


# ------------------------------------------------------------
#  RouteTable
# ------------------------------------------------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_a_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_sub_a.id
}

resource "aws_route_table_association" "public_route_c_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_sub_c.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name}-private-route-table"
  }
}

resource "aws_route_table_association" "private_route_a_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_sub_a.id
}

resource "aws_route_table_association" "private_route_c_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_sub_c.id
}

# ------------------------------------------------------------
#  Internet Gateway
# ------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.tag_name}-igw"
  }
}

resource "aws_route" "public_route_igw_r" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}
