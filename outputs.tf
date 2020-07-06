# # 子モジュールから出力値を受け取る
# output "iamrole" {
#   value = module.describe_regions_for_ec2.iam_role_arn
# }

# ALB
output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

# ネームサーバー
output "name_servers" {
  value = aws_route53_zone.example.name_servers
}