
resource "aws_security_group" "allow_ejabberd" {
  name        = "allow_ejabberd_${var.environment}"
  description = "Allow required ports for Ejabberd inbound traffic"
  vpc_id      = var.main_vpc.id 

  ingress {
    description      = "Allow ssh."
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "The default port for XMPP clients."
    from_port        = 5222
    to_port          = 5222
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "The legacy port for XMPP clients."
    from_port        = 5223
    to_port          = 5223
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "MQTT"
    from_port        = 1883
    to_port          = 1883
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Ejabberd http port"
    from_port        = 80
    to_port          = 5280
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Ejabberd http port"
    from_port        = 5280
    to_port          = 5280
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Ejabberd https port"
    from_port        = 5443
    to_port          = 5443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ejabberd"
  }
}
