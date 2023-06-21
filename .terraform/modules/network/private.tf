resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_a_subnet_cidr
  availability_zone = "eu-central-1a"
  tags = {
    Name        = "app-${var.environment}-private-a"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_b_subnet_cidr
  availability_zone = "eu-central-1b"
  tags = {
    Name        = "app-${var.environment}-private-b"
    Environment = var.environment
  }
}
