
output "main_vpc" {
    value = aws_vpc.main
}

output "subnet_public_a" {
    value = aws_subnet.public_a
}

output "subnet_nat_a" {
    value = aws_subnet.nat_a
}

output "subnet_nat_b" {
    value = aws_subnet.nat_b
}

output "internet_gateway" {
    value = aws_internet_gateway.main
}

output "aws_lb_main" {
  value = aws_lb.main
}
