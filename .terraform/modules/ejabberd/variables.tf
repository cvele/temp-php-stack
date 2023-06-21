variable "ejabberd_ec2_instance_type" {
  type = string
  description = "ec2 instance type to use"
  default     = "t4g.nano"
}

variable "environment" {
  type = string
  description = "env"
  default     = "production"
}

variable "primary_dns_zone" {
  type = any
  description = "primary dns zone. all dns records will be created under"
}


variable "aws_lb_main" {
  type = any
  description = "main load balancer. target groups will be attached to listeners here"
}
variable "ejabberd_db_name" {
  type = string
  default = "ejabberd"
}

variable "rds_credentials_secret" {
  type = any
  description = "Secret containing RDS credentials"
}
variable "ec2_depends_on" {
  type = any
  default = []
}
variable "auth_provider_host" {
  type = string
  description = "http://host:port"
}

variable "main_vpc" {
  type = any
  description = "vpc"
}

variable "main_key_pair" {
  type = any
  description = "aws_key_pair object"
}

variable "subnet_nat_a" {
  type = any
  description = "vpc"
}
