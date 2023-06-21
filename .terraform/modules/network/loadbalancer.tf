resource "aws_lb" "main" {
  name                       = "app-${var.environment}-nlb"
  internal                   = false
  enable_deletion_protection = false
  load_balancer_type         = "network"
  subnets                    = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags = {
    Name        = join("-", [var.environment, "nlb", "ab"])
    Environment = var.environment
  }
}
