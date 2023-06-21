variable "ami_name" {
  type    = string
  default = "app-ejabberd"
}

variable "aws_access_key_id" {
  type = string
  default = env("AWS_ACCESS_KEY_ID")
}

variable "aws_secret_access_key_id" {
  type = string
  default = env("AWS_SECRET_ACCESS_KEY")
}

variable "ami_version" {
  type = string
  default = env("EJABBERD_AMI_VERSION")
}

variable "os_version" {
  type = string
  default = "Ubuntu-20.04-arm64"
}

source "null" "aws-secret-manager" {
  communicator = "none"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "ejabberd" {
  access_key    = var.aws_access_key_id
  secret_key    = var.aws_secret_access_key_id
  ssh_username  = "ubuntu"
  ami_name      = "${var.ami_name}-${var.ami_version}"
  instance_type = "t4g.large"
  region        = "eu-central-1"
  subnet_id     = "subnet-0e813f2644dc85e60"
  associate_public_ip_address = false
  force_deregister = true
  force_delete_snapshot = true

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] #var.owners
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
  }
  
  snapshot_tags = {
    OS_Version = var.os_version
    Release = "Latest"
    Base_AMI_ID = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}-${var.ami_version}"
    Name = "${var.ami_name}-${var.ami_version}"
  }
  
  tags = {
    OS_Version = var.os_version
    Release = "Latest"
    Base_AMI_ID = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}-${var.ami_version}"
    Name = "${var.ami_name}-${var.ami_version}"
  }
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.ejabberd"]
  name = "${var.ami_name}-${var.ami_version}"
  
  provisioner "file" {
    source = "./ejabberd.tpl.yml"
    destination = "/home/ubuntu/ejabberd.tpl.yml"
  }

  provisioner "shell" {
    execute_command = "/usr/bin/cloud-init status --wait && sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
        "mkdir -p /etc/ejabberd",
        "mv /home/ubuntu/ejabberd.tpl.yml /etc/ejabberd/ejabberd.tpl.yml",
        "DEBIAN_FRONTEND=noninteractive apt-get update",
        "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
        "DEBIAN_FRONTEND=noninteractive apt-get -y install awscli erlang-p1-mysql ejabberd ejabberd-contrib jq mysql-client wait-for-it",
        "service ejabberd start",
        "ejabberdctl modules_update_specs",
        "ejabberdctl module_install ejabberd_auth_http",
        "service ejabberd stop",
    ]
  }
}
