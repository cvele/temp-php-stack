resource "aws_iam_role" "ejabberd_iam_role" {
  name = "ejabberd_iam_role_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "ejabberd_iam_role_${var.environment}"
  }
}
resource "aws_iam_role_policy" "ejabberd_secretmanager_policy" {
  name = "ejabberd_secretmanager_policy_${var.environment}"
  role = "${aws_iam_role.ejabberd_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${aws_secretsmanager_secret.jabber_admin_password.arn}"
    },
    {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${var.rds_credentials_secret.arn}"
    }]
}
EOF
}

resource "aws_iam_instance_profile" "ejabberd_instance_profile" {
  name = "ejabberd-instance-profile-${var.environment}"
  role = "${aws_iam_role.ejabberd_iam_role.name}"
}
