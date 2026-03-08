resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidrs

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-vpc-tf-${var.name}" : "${var.tags.Environment}-vpc-${var.name}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-public-subnet-tf-${var.name}-${count.index + 1}" : "${var.tags.Environment}-public-subnet-${var.name}-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-private-subnet-tf-${var.name}-${count.index + 1}" : "${var.tags.Environment}-private-subnet-${var.name}-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-gw-tf-${var.name}" : "${var.tags.Environment}-gw-${var.name}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-public-routetb-tf-${var.name}" : "${var.tags.Environment}-public-routetb-${var.name}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.tags.Terraform == "true" ? "${var.tags.Environment}-private-routetb-tf-${var.name}" : "${var.tags.Environment}-private-routetb-${var.name}"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}