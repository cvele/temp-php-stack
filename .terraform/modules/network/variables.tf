variable "environment" {
  type = string
  description = "env"
  default     = "production"
}

variable "public_a_subnet_cidr" {
  type = string
}
variable "public_b_subnet_cidr" {
  type = string
}

variable "nat_a_subnet_cidr" {
  type = string
}
variable "nat_b_subnet_cidr" {
  type = string
}

variable "private_a_subnet_cidr" {
  type = string
}
variable "private_b_subnet_cidr" {
  type = string
}
variable "cidr_block" {
  type = string
}

