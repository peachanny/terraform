# security_group.idをoutput
output "security_group_id" {
  value = aws_security_group.default.id
}