# ECSクラスタ（ホスト）
resource "aws_ecs_cluster" "example" {
  name = "terraform-ecs"
}


# タスク定義
resource "aws_ecs_task_definition" "example" {
  family = "terraform-ecs-task"
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = file("./container_definitions.json")
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}


# ECSサービスの定義
resource "aws_ecs_service" "example" {
  name = "terraform-ecs-service"
  cluster = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.example.arn
  # 維持するタスク数
  # ECS サービスは起動するタスクの数を定義でき、指定した数のタスクを維持します。
  desired_count = 2
  launch_type = "FARGATE"
  platform_version = "1.3.0"
  # デフォルトは 0 秒です。タスクの起動に時間がかかる場合、⼗分な猶予期間を設定しておかないと、
  # ヘルスチェックに引っかかり、タスクの起動 と終了が無限に続いてしまいます。
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name = "example"
    container_port = 80
  }

  # デプロイのたびにタスク定義が更新され、plan 時に差分が出ます。 よって、Terraform ではタスク定義の変更を無視すべきです。
  lifecycle {
    ignore_changes = [task_definition]
  }
}


# CloudWatch Logsの定義
resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/example"
  retention_in_days = 180
}
