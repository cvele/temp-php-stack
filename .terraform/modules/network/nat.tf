resource "aws_subnet" "nat_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.nat_a_subnet_cidr
  availability_zone = "eu-central-1a"
  tags = {
    Name        = "app-${var.environment}-nat-a"
    Environment = var.environment
  }
}

resource "aws_subnet" "nat_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.nat_b_subnet_cidr
  availability_zone = "eu-central-1b"
  tags = {
    Name        = "app-${var.environment}-nat-b"
    Environment = var.environment
  }
}

resource "aws_eip" "nat_a" {
  vpc = true
  tags = {
    Name        = "app-${var.environment}-nat-a"
    Environment = var.environment
  }
}

resource "aws_eip" "nat_b" {
  vpc = true
  tags = {
    Name        = "app-${var.environment}-nat-b"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "app_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name        = "app-${var.environment}-nat-a"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "app_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
  tags = {
    Name        = "app-${var.environment}-nat-b"
    Environment = var.environment
  }
}

resource "aws_route_table" "app-nat-a" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "app-${var.environment}-nat-a"
    Environment = var.environment
  }
}

resource "aws_route_table" "app-nat-b" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "app-${var.environment}-nat-b"
    Environment = var.environment
  }
}

resource "aws_route" "app-nat-a" {
  nat_gateway_id         = aws_nat_gateway.app_a.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.app-nat-a.id
}

resource "aws_route" "app-nat-b" {
  nat_gateway_id         = aws_nat_gateway.app_b.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.app-nat-b.id
}

resource "aws_route_table_association" "app-nat-a" {
  subnet_id      = aws_subnet.nat_a.id
  route_table_id = aws_route_table.app-nat-a.id
}

resource "aws_route_table_association" "app-nat-b" {
  subnet_id      = aws_subnet.nat_b.id
  route_table_id = aws_route_table.app-nat-b.id
}
