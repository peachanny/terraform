# 毎回egressも作成されてしまうのでなんとかしたい
# • name - セキュリティグループの名前
# • vpc_id - VPC の ID
# • port - 通信を許可するポート番号
# • cidr_blocks - 通信を許可する CIDR ブロック
variable "name" {}
variable "vpc_id" {}
variable "port" {}
variable "cidr_blocks" {
  type = list(string)
}


# セキュリティグループの定義
resource "aws_security_group" "default" {
  name = var.name
  vpc_id = var.vpc_id
}


# セキュリティグループルール（インバウンド）
resource "aws_security_group_rule" "ingress" {
  type = "ingress"
  from_port = var.port
  to_port = var.port
  protocol = "tcp"
  cidr_blocks = var.cidr_blocks
  security_group_id = aws_security_group.default.id
}


# セキュリティグループルール（アウトバウンド）
resource "aws_security_group_rule" "egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
