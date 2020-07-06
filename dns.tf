# ホストゾーン作成
resource "aws_route53_zone" "example" {
  name = "practicedomain.work"
}

# DNSレコード
resource "aws_route53_record" "example" {
  zone_id = aws_route53_zone.example.id
  name = aws_route53_zone.example.name
  type = "A"

  alias {
    name = aws_lb.example.dns_name
    zone_id = aws_lb.example.zone_id
    evaluate_target_health = true
  }
}


# SSL証明書
resource "aws_acm_certificate" "example" {
  domain_name = aws_route53_zone.example.name
  subject_alternative_names = []
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


# SSL証明書の検証用レコード
# DNS検証のACMを新規作成→DNS検証に用いる、CNAMEレコードが発行される→CNAMEレコードを(AWSでDNS検証を行うのなら)Route53に登録する
resource "aws_route53_record" "example_certificate" {
  name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
  zone_id = aws_route53_zone.example.id
  ttl     = 60
}


# 検証の待機
# *apply 時に SSL 証明書の検証が完了するまで待ってくれます
resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.example.arn
  validation_record_fqdns = [aws_route53_record.example_certificate.fqdn]
}