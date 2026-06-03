locals {
  # Atualizado em: 2025-08. Fonte: https://www.cloudflare.com/ips-v4
  cloudflare_ipv4 = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22",
  ]
}

resource "aws_security_group" "bolao" {
  name        = "bolao-da-copa"
  description = "Bolao da Copa - Cloudflare 80/443 e SSH 22"
  vpc_id      = data.aws_vpc.default.id

  # HTTP — apenas IPs da Cloudflare
  ingress {
    description = "HTTP via Cloudflare"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.cloudflare_ipv4
  }

  # HTTPS — apenas IPs da Cloudflare
  ingress {
    description = "HTTPS via Cloudflare"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.cloudflare_ipv4
  }

  # SSH — aberto para qualquer IP (necessário para GitHub Actions com IPs dinâmicos)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "bolao-da-copa"
    Project = "bolao-da-copa"
  }
}
