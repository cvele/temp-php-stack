data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

variable "main_vpc" {
  type = any
  description = "vpc"
}

variable "subnet_public_a" {
  type = any
  description = "subnet"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"
  vpc_id      = var.main_vpc.id 

  ingress {
    description      = "Allow ssh."
    from_port        = 22
    to_port          = 22
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
    Name = "allow_ssh"
  }
}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t4g.nano"
    key_name = aws_key_pair.app_rs.key_name
    subnet_id = var.subnet_public_a.id
    vpc_security_group_ids = [aws_security_group.allow_ssh.id] 
    associate_public_ip_address = true
    tags = {
        Name = "bastion"
    }
}

resource "aws_key_pair" "app_rs" {
  key_name   = "app_rs"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFBgqPUQo4f1JzmRjQh3LxIBV7gm2tfiGGpCS0joKfHE app_rs"
}

resource "aws_route53_record" "bastion" {
  zone_id = var.primary_dns_zone.id
  name    = "_.app.rs"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.bastion.public_ip}"]
}

variable "primary_dns_zone" {
  type = any
  description = "primary dns zone. all dns records will be created under"
}

output "main_key_pair" {
    value = aws_key_pair.app_rs
}
