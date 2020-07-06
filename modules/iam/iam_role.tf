# • name - IAM ロールと IAM ポリシーの名前
# • policy - ポリシードキュメント
# • identifier - IAM ロールを紐づける AWS のサービス識別⼦
variable "name" {}
variable "policy" {}
variable "identifier" {}

# IAMロール
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# 信用ポリシー（関連付けたいサービス）
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}


# IAMポリシー
resource "aws_iam_policy" "default" {
  name   = var.name
  policy = var.policy
}

# IAMポリシーのアタッチ
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

