resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_a_subnet_cidr
  availability_zone = "eu-central-1a"
  tags = {
    Name        = join("-", [var.environment, "public", "a"])
    Environment = var.environment
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_b_subnet_cidr
  availability_zone = "eu-central-1b"
  tags = {
    Name        = join("-", [var.environment, "public", "b"])
    Environment = var.environment
  }
}

resource "aws_route_table" "app-public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = join("-", [var.environment, "app"])
    Environment = var.environment
  }
}

resource "aws_route" "app-public" {
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.app-public.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = join("-", [var.environment, "app"])
    Environment = var.environment
  }
}

resource "aws_route_table_association" "app-public-a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.app-public.id
}

resource "aws_route_table_association" "app-public-b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.app-public.id
}
