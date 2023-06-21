resource "random_password" "default_master_password" {
  length  = 16
  special = false
}

resource "aws_security_group" "rds" {
  name        = "allow_mysql"
  description = "RDS MySQL server"
  vpc_id      = var.main_vpc.id
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = [var.main_vpc.cidr_block]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_mysql"
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "main_"
  subnet_ids = [var.subnet_nat_a.id, var.subnet_nat_b.id]

  tags = {
    Name = "db_subnet_private__ab"
  }
}
resource "aws_db_instance" "default" {
  identifier                = "${var.name}-${var.environment}"
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  db_name                   = "${var.name}_${var.environment}"
  username                  = var.username
  password                  = random_password.default_master_password.result
  parameter_group_name      = "default.mysql5.7"
  skip_final_snapshot       = true
  apply_immediately         = true
  backup_retention_period   = 0
  publicly_accessible       = false
  multi_az                  = false
  vpc_security_group_ids    = [aws_security_group.rds.id]
  db_subnet_group_name      = aws_db_subnet_group.default.name
  deletion_protection       = true
  depends_on = [var.subnet_nat_a, var.subnet_nat_b]
  tags = {
      Name = join("-", [var.name, var.environment])
  }
}


resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "app/${var.environment}/db/${var.name}"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_db_instance.default.username}",
  "password": "${random_password.default_master_password.result}",
  "engine": "mysql",
  "host": "${aws_route53_record.db_internal.name}",
  "port": ${aws_db_instance.default.port},
  "dbClusterIdentifier": "${aws_db_instance.default.identifier}"
}
EOF
}

resource "aws_route53_record" "db_internal" {
  zone_id = var.primary_dns_zone.id
  name    = "db.internal.app.rs"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_db_instance.default.address]
  depends_on = [var.primary_dns_zone]
}
