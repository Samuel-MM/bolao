data "aws_ami" "ubuntu_24" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "bolao_deploy" {
  key_name   = "bolao-deploy"
  public_key = var.public_key
}

resource "aws_instance" "bolao" {
  ami                    = data.aws_ami.ubuntu_24.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.bolao_deploy.key_name
  vpc_security_group_ids = [aws_security_group.bolao.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ebs_volume_size
    encrypted   = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Atualiza o sistema
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get upgrade -y -qq

    # Instala Docker (repositório oficial)
    apt-get install -y -qq ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -qq
    apt-get install -y -qq \
      docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin

    # Adiciona ubuntu ao grupo docker
    usermod -aG docker ubuntu

    # Cria estrutura de diretórios da aplicação
    mkdir -p /data/postgres
    mkdir -p /srv/bolao/nginx
    mkdir -p /srv/bolao/certs
    chown -R ubuntu:ubuntu /srv/bolao
  EOF

  tags = {
    Name    = "bolao-da-copa"
    Project = "bolao-da-copa"
  }
}

resource "aws_eip" "bolao" {
  instance = aws_instance.bolao.id
  domain   = "vpc"

  tags = {
    Name    = "bolao-da-copa"
    Project = "bolao-da-copa"
  }
}
