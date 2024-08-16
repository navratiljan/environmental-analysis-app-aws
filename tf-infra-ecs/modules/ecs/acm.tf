resource "aws_route53_zone" "primary" {
  name = var.base_dns_name
}

resource "aws_route53_record" "alb_cname" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.application_name
  type    = "CNAME"
  ttl     = 10


  records = [aws_lb.public-lb.dns_name]
}

resource "aws_route53_health_check" "alb_health_check" {
  fqdn              = aws_lb.public-lb.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = "30"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${aws_route53_record.alb_cname.name}.${aws_route53_zone.primary.name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.primary.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}