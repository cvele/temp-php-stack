output "rds_credentials_secret" {
  value = aws_secretsmanager_secret.rds_credentials
}

output "rds" {
  value = aws_db_instance.default
}
