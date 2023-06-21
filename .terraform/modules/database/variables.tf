variable "environment" {
  type = string
  description = "env"
  default     = "production"
}

variable "name" {
  type = string
  description = "env"
  default     = "apprs"
}

variable "username" {
  type          = string
  description   = "mysql root username"
  default       = "app"
}

variable "main_vpc" {
  type          = any
  default       = "vpc"
}

variable "subnet_nat_a" {
  type = any
  description = "vpc"
}
variable "subnet_nat_b" {
  type = any
  description = "vpc"
}

variable "primary_dns_zone" {
  type = any
  description = "primary dns zone. all dns records will be created under"
}
