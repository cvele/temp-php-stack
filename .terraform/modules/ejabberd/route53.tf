resource "aws_route53_record" "jabber_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "jabber.app.rs"
  type    = "A"
  alias {
    name                   = var.aws_lb_main.dns_name
    zone_id                = var.aws_lb_main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "www.app.rs"
  type    = "A"
  alias {
    name                   = var.aws_lb_main.dns_name
    zone_id                = var.aws_lb_main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "app.rs"
  type    = "A"
  alias {
    name                   = var.aws_lb_main.dns_name
    zone_id                = var.aws_lb_main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "pubsub_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "pubsub.app.rs"
  type    = "A"
  alias {
    name                   = var.aws_lb_main.dns_name
    zone_id                = var.aws_lb_main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "pubsub_jabber_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "pubsub.jabber.app.rs"
  type    = "A"
  alias {
    name                   = var.aws_lb_main.dns_name
    zone_id                = var.aws_lb_main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "_jabber__tcp_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "_jabber._tcp.app.rs"
  type    = "SRV"
  ttl     = "60"
  records = ["0 0 5269 jabber.app.rs."]
}

resource "aws_route53_record" "_xmpp-client__tcp_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "_xmpp-client._tcp.app.rs"
  type    = "SRV"
  ttl     = "60"
  records = ["0 0 5222 jabber.app.rs."]
}

resource "aws_route53_record" "_xmpp_server__tcp_app_rs" {
  zone_id = var.primary_dns_zone.id
  name    = "_xmpp-server._tcp.app.rs"
  type    = "SRV"
  ttl     = "60"
  records = ["0 0 5269 jabber.app.rs."]
}


