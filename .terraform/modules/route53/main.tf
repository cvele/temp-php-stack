resource "aws_route53_zone" "primary" {
  name = "app.rs"
}

output "primary_dns_zone" {
  value = aws_route53_zone.primary
}
