# ⚽ Bolão da Copa 2026

Plataforma de bolão para a Copa do Mundo 2026. Participantes entram em grupos via convite, apostam no placar dos jogos, pagam via PIX e concorrem ao prêmio acumulado de cada partida.

---

## Funcionalidades

- **Grupos por convite** — o admin cria o bolão e compartilha o link; participantes solicitam entrada e são aprovados manualmente
- **Apostas por placar** — cada participante aposta no placar exato de cada jogo antes do início da partida
- **Pagamento via PIX** — QR Code gerado automaticamente com código EMV/BR Code; participante envia comprovante direto para o S3
- **Confirmação manual** — admin visualiza o comprovante e aprova ou rejeita com justificativa (participante recebe e-mail)
- **Reembolso** — participante pode solicitar reembolso; após aprovação do admin, a aposta é cancelada e liberada para nova aposta
- **Resultados automáticos** — integração com API Football sincroniza placares a cada 30 minutos via job em background
- **Premiação** — ao encerrar um jogo, o sistema calcula quem acertou o placar exato e distribui o prêmio; se ninguém acertar, o valor acumula
- **E-mails transacionais** — notificações para confirmação de conta, redefinição de senha, status de pagamento, resultado e premiação
- **Painel admin** — gestão completa de participantes, pagamentos, jogos e resultados

---

## Stack

| Camada | Tecnologia |
|---|---|
| Backend | Ruby on Rails 8.1 |
| Frontend | Hotwire (Turbo + Stimulus) + Tailwind CSS |
| Banco de dados | PostgreSQL 18 |
| Jobs | GoodJob 4 |
| Autenticação | Devise |
| Upload | AWS S3 |
| E-mail | Gmail SMTP |
| Resultados | API Football |
| Deploy | Docker + GitHub Actions |
| Infra | AWS EC2 t3a.micro + Cloudflare |

---

## Rodando localmente

### Pré-requisitos

- Ruby 3.4.x
- Docker
- Node.js
### Setup

```bash
# Clone o repositório
git clone https://github.com/Samuel-MM/bolao.git
cd bolao

# Instale as dependências
bundle install

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o .env com seus valores

# Suba o banco de dados
docker run -d \
  --name bolao-postgres \
  -e POSTGRES_USER=bolao \
  -e POSTGRES_PASSWORD=bolao \
  -p 5433:5432 \
  postgres:18-alpine

# Crie o banco e rode as migrations
bin/rails db:create db:migrate

# Popule com dados iniciais (opcional)
bin/rails db:seed

# Inicie o servidor
bin/dev
```

Acesse em [http://localhost:3000](http://localhost:3000).

---

## Variáveis de ambiente

Copie `.env.example` para `.env` e preencha:

| Variável | Descrição |
|---|---|
| `DATABASE_URL` | URL de conexão com o PostgreSQL |
| `PIX_KEY` | Chave PIX do recebedor |
| `PIX_MERCHANT_NAME` | Nome do recebedor (aparece no QR Code) |
| `AWS_ACCESS_KEY_ID` | Credencial AWS para acesso ao S3 |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS para acesso ao S3 |
| `AWS_S3_BUCKET` | Nome do bucket dos comprovantes |
| `API_FOOTBALL_KEY` | Chave da API Football |
| `SMTP_USERNAME` | E-mail do remetente (Gmail) |
| `SMTP_PASSWORD` | App Password do Gmail (sem espaços) |
| `RAILS_MASTER_KEY` | Chave de decriptação das credentials do Rails |

---

## Testes

```bash
bin/rails test
```

A suite cobre os modelos principais: `User`, `Pool`, `PoolMembership`, `Match`, `Bet`, `Payment` e os services de PIX e resultado.

---

## Deploy

O deploy é automático via GitHub Actions a cada push na branch `main`:

```
push main → testes → build Docker → push Docker Hub → SSH EC2 → migrate → restart
```

### Infraestrutura provisionada com Terraform

```bash
cd terraform
terraform init
terraform apply
```

Recursos criados:
- EC2 t3a.micro (Ubuntu 24.04 LTS)
- Elastic IP estático
- Security Group (80/443 só Cloudflare, 22 aberto)
- IAM user dedicado com acesso mínimo ao S3
- Key pair SSH

### Secrets necessários no GitHub

| Secret | Descrição |
|---|---|
| `DOCKERHUB_USERNAME` | Usuário Docker Hub |
| `DOCKERHUB_TOKEN` | Token de acesso Docker Hub |
| `EC2_HOST` | Elastic IP da EC2 |
| `EC2_SSH_KEY` | Chave privada SSH |

---

## Arquitetura

```
Cloudflare (proxy + SSL Full Strict)
    │
    ▼
Nginx (443 → Origin Certificate)
    │
    ▼
Thruster → Puma (Rails)
    │
    ├── PostgreSQL (container, volume em /data/postgres)
    └── GoodJob (worker separado, mesmo container image)
```

---

## Licença

Projeto pessoal — todos os direitos reservados.
