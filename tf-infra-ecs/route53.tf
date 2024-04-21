resource "aws_route53_zone" "primary" {
  name = "navaws.ceacpoc.cloud"
}

resource "aws_route53_record" "alb_cname" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "envstats"
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