variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "public_key" {
  description = "Conteúdo da chave pública SSH (ex: ssh-ed25519 AAAA...)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3a.micro"
}

variable "app_bucket_name" {
  description = "Nome do bucket S3 para comprovantes de pagamento"
  type        = string
  default     = "bolao-copa-2026"
}

variable "ebs_volume_size" {
  description = "Tamanho do volume EBS raiz em GB"
  type        = number
  default     = 20
}
