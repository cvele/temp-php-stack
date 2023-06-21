
resource "aws_lb_target_group" "ejabberd_5222" {
  name     = "ejabberd-5222-${var.environment}-tg"
  port     = 5222
  protocol = "TCP"
  vpc_id   = var.main_vpc.id
}

resource "aws_lb_target_group" "ejabberd_5223" {
  name     = "ejabberd-5223-${var.environment}-tg"
  port     = 5223
  protocol = "TCP"
  vpc_id   = var.main_vpc.id
}

resource "aws_lb_target_group" "ejabberd_1883" {
  name     = "ejabberd-1883-${var.environment}-tg"
  port     = 1883
  protocol = "TCP"
  vpc_id   = var.main_vpc.id
}

resource "aws_lb_target_group" "ejabberd_5280" {
  name     = "ejabberd-5280-${var.environment}-tg"
  port     = 5280
  protocol = "TCP"
  vpc_id   = var.main_vpc.id
}

resource "aws_lb_target_group" "ejabberd_5443" {
  name     = "ejabberd-5443-${var.environment}-tg"
  port     = 5443
  protocol = "TCP"
  vpc_id   = var.main_vpc.id
}

resource "aws_lb_target_group_attachment" "main5222" {
  target_group_arn = aws_lb_target_group.ejabberd_5222.arn
  target_id        = aws_instance.ejabberd.id
  port             = 5222
}

resource "aws_lb_target_group_attachment" "main5223" {
  target_group_arn = aws_lb_target_group.ejabberd_5223.arn
  target_id        = aws_instance.ejabberd.id
  port             = 5223
}

resource "aws_lb_target_group_attachment" "main1883" {
  target_group_arn = aws_lb_target_group.ejabberd_1883.arn
  target_id        = aws_instance.ejabberd.id
  port             = 1883
}

resource "aws_lb_target_group_attachment" "main5443" {
  target_group_arn = aws_lb_target_group.ejabberd_5443.arn
  target_id        = aws_instance.ejabberd.id
  port             = 5443
}

resource "aws_lb_target_group_attachment" "main5280" {
  target_group_arn = aws_lb_target_group.ejabberd_5280.arn
  target_id        = aws_instance.ejabberd.id
  port             = 5280
}

resource "aws_lb_target_group_attachment" "main80" {
  target_group_arn = aws_lb_target_group.ejabberd_5280.arn
  target_id        = aws_instance.ejabberd.id
  port             = 80
}

resource "aws_lb_listener" "main5222" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "5222"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_5222.arn
  }
}

resource "aws_lb_listener" "main5223" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "5223"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_5223.arn
  }
}

resource "aws_lb_listener" "main1883" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "1883"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_1883.arn
  }
}

resource "aws_lb_listener" "main5280" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "5280"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_5280.arn
  }
}

resource "aws_lb_listener" "main80" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_5280.arn
  }
}

resource "aws_lb_listener" "main5443" {
  load_balancer_arn = var.aws_lb_main.arn
  port              = "5443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ejabberd_5443.arn
  }
}
