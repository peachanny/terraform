# ALB
resource "aws_lb" "example" {
  name = "terraform-alb"
  load_balancer_type = "application"
  # インターネット向けかVPC内部向けか
  internal = false
  idle_timeout = 60
  # 削除保護
  enable_deletion_protection = true

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id
  ]

  access_logs {
    bucket = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    # HTTP を HTTPS にリダイレクト
    module.http_redirect_sg.security_group_id
  ]
}



# リスナー(http)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  # いずれの ルールにも合致しない場合は、default_actionの定義内容が実⾏されます
  default_action {
    type = "fixed-response" 

    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTP」です"
      status_code = "200"
    }
  }
}


# リスナー（https）
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.example.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTPS」です"
      status_code = "200"
    }
  }
}


# リスナー（HTTP から HTTPS にリダイレクト）
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



# ターゲットグループ
resource "aws_lb_target_group" "example" {
  name = "terraform-alb-target"
  vpc_id = aws_vpc.example.id
  target_type = "ip"
  port = 80
  protocol = "HTTP"
  deregistration_delay = 300

  health_check {
    path = "/"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = 200
    port = "traffic-port"
    protocol = "HTTP"
  }

  depends_on = [aws_lb.example]
}


# リスナールール
resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}