output "elastic_ip" {
  description = "IP estático da EC2 — configure este valor em: GitHub Secret EC2_HOST e DNS Cloudflare"
  value       = aws_eip.bolao.public_ip
}

output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.bolao.id
}

output "iam_access_key_id" {
  description = "AWS_ACCESS_KEY_ID para o .env de produção na EC2"
  value       = aws_iam_access_key.bolao_app.id
}

output "iam_secret_access_key" {
  description = "AWS_SECRET_ACCESS_KEY para o .env de produção na EC2 — execute: terraform output -raw iam_secret_access_key"
  value       = aws_iam_access_key.bolao_app.secret
  sensitive   = true
}
