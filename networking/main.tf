resource "aws_vpc" "dev_arch_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    "Name" = "dev_arch_vpc"
  }
}
data "aws_availability_zones" "available" {

}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 20
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.dev_arch_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.dev_arch_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "dev_arch_igw" {
  vpc_id = aws_vpc.dev_arch_vpc.id
  tags = {
    Name = "dev-arch-vpc-igw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.dev_arch_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_arch_igw.id
  }
  tags = {
    Name = "Public route"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route.id
}
resource "aws_security_group" "dev_arch_sec_group" {
  vpc_id = aws_vpc.dev_arch_vpc.id
  name   = "allow http access"
  ingress {
    description = "Ingress rules"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "my_sg"
  }
}