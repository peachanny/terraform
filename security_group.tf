# module "example_sg" {
#   source = "./modules/security_group"
#   name = "module-sg"
#   vpc_id = aws_vpc.example.id
#   port = 80
#   cidr_blocks = ["0.0.0.0/0"]
# }

# http
module "http_sg" {
  source = "./modules/security_group"
  name = "http-sg"
  vpc_id = aws_vpc.example.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

# https
module "https_sg" {
  source = "./modules/security_group"
  name = "https-sg"
  vpc_id = aws_vpc.example.id
  port = 443
  cidr_blocks = ["0.0.0.0/0"]
}

# httpredirect（HTTP を HTTPS にリダイレクト）
module "http_redirect_sg" {
  source = "./modules/security_group"
  name = "http-redirect-sg"
  vpc_id = aws_vpc.example.id
  port = 8080
  cidr_blocks = ["0.0.0.0/0"]
}


# nginx
module "nginx_sg" {
  source = "./modules/security_group"
  name = "nginx-sg"
  vpc_id = aws_vpc.example.id
  port = 80
  cidr_blocks = [aws_vpc.example.cidr_block]
}