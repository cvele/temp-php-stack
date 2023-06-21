data "aws_ami" "ejabberd" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["app-ejabberd-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
