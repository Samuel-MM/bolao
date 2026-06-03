# O bucket bolao-copa-2026 já existe e é gerenciado fora do Terraform.
# O Terraform só gerencia o IAM user dedicado para a aplicação acessá-lo.

locals {
  app_bucket_arn = "arn:aws:s3:::${var.app_bucket_name}"
}

resource "aws_iam_user" "bolao_app" {
  name = "bolao-app"

  tags = {
    Project = "bolao-da-copa"
  }
}

resource "aws_iam_access_key" "bolao_app" {
  user = aws_iam_user.bolao_app.name
}

resource "aws_iam_user_policy" "bolao_app_s3" {
  name = "bolao-app-s3"
  user = aws_iam_user.bolao_app.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${local.app_bucket_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = local.app_bucket_arn
      }
    ]
  })
}
