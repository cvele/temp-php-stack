resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name        = "app-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_main_route_table_association" "app-main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.app-main.id
}

resource "aws_route_table" "app-main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "app-${var.environment}-main"
    Environment = var.environment
  }
}

resource "aws_network_acl" "app" {
  vpc_id = aws_vpc.main.id
  egress {
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    icmp_code       = 0
    icmp_type       = 0
    ipv6_cidr_block = null
    protocol        = "-1"
    rule_no         = 100
    to_port         = 0
  }
  ingress {
    protocol        = "-1"
    rule_no         = 100
    action          = "allow"
    cidr_block      = "0.0.0.0/0"
    from_port       = 0
    to_port         = 0
    ipv6_cidr_block = null
    icmp_code       = 0
    icmp_type       = 0
  }
  tags = {
    Name        = "app-${var.environment}"
    Environment = var.environment
  }
}
