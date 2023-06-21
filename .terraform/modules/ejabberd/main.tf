resource "random_password" "ejabberd_admin_password" {
  length  = 16
  special = false
}


resource "aws_instance" "ejabberd" {
    key_name = var.main_key_pair.key_name
    ami = data.aws_ami.ejabberd.id
    instance_type = var.ejabberd_ec2_instance_type
    subnet_id = var.subnet_nat_a.id
    vpc_security_group_ids = [aws_security_group.allow_ejabberd.id] 
    associate_public_ip_address = false
    iam_instance_profile = "${aws_iam_instance_profile.ejabberd_instance_profile.name}"
    user_data = base64encode(templatefile("${path.module}/user_data.sh", {
        environment = var.environment,
        rds_credentials_secret_name = var.rds_credentials_secret.name,
        ejabberd_db_name = var.ejabberd_db_name,
        ejabberd_admin_password = random_password.ejabberd_admin_password.result
        auth_provider_host = var.auth_provider_host
    }))
    tags = {
        Name = "${data.aws_ami.ejabberd.name}-${var.environment}-0"
    }
    depends_on = [var.ec2_depends_on]
}

resource "aws_secretsmanager_secret" "jabber_admin_password" {
  name = "app/${var.environment}/ejabberd/jabber_admin_password"
}

resource "aws_secretsmanager_secret_version" "jabber_admin_password" {
  secret_id     = aws_secretsmanager_secret.jabber_admin_password.id
  secret_string = random_password.ejabberd_admin_password.result
}

