# ⚽ Bolão da Copa 2026

Plataforma de bolão para a Copa do Mundo 2026. Participantes entram em grupos via convite, apostam no placar dos jogos, pagam via PIX e concorrem ao prêmio acumulado de cada partida.

---

## Funcionalidades

- **Grupos por convite** — o admin cria o bolão e compartilha o link; participantes solicitam entrada e são aprovados manualmente
- **Apostas por placar** — cada participante aposta no placar exato de cada jogo antes do início da partida
- **Pagamento via PIX** — QR Code gerado automaticamente com código EMV/BR Code; participante envia comprovante direto para o S3
- **Confirmação manual** — admin visualiza o comprovante e aprova ou rejeita com justificativa (participante recebe e-mail)
- **Reembolso** — participante pode solicitar reembolso; após aprovação do admin, a aposta é cancelada e liberada para nova aposta
- **Resultados automáticos** — integração com football-data.org sincroniza placares a cada 10 minutos via GoodJob
- **Premiação** — ao encerrar um jogo, o sistema calcula quem acertou o placar exato e distribui o prêmio; se ninguém acertar, o valor acumula. O admin pode adicionar um prêmio bônus fixo por jogo que se soma ao valor arrecadado
- **E-mails transacionais** — notificações para confirmação de conta, redefinição de senha, status de pagamento, resultado e premiação
- **Painel admin** — gestão completa de participantes, pagamentos, jogos e resultados; lista de apostas por jogo com chaves PIX dos vencedores
- **Notificação ao admin** — e-mail automático quando um participante solicita entrada em um bolão

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
| Resultados | football-data.org API v4 |
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
| `APP_HOST` | Domínio da aplicação (ex: `meubolao.com.br`) — usado nos links dos e-mails |
| `PIX_KEY` | Chave PIX do recebedor |
| `PIX_MERCHANT_NAME` | Nome do recebedor (aparece no QR Code) |
| `AWS_ACCESS_KEY_ID` | Credencial AWS para acesso ao S3 |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS para acesso ao S3 |
| `AWS_REGION` | Região do bucket S3 (padrão: `us-east-1`) |
| `AWS_S3_BUCKET` | Nome do bucket dos comprovantes |
| `FOOTBALL_DATA_API_KEY` | Chave da API football-data.org |
| `SMTP_USERNAME` | E-mail do remetente (Gmail) |
| `SMTP_PASSWORD` | App Password do Gmail (sem espaços) |
| `RAILS_MASTER_KEY` | Chave de decriptação das credentials do Rails |

---

## Integração com football-data.org

Os jogos são sincronizados automaticamente com a [football-data.org API v4](https://www.football-data.org/).

### Cadastrando um jogo

1. Obtenha o ID do jogo na API:
   ```
   GET https://api.football-data.org/v4/competitions/WC/matches?season=2026
   X-Auth-Token: <sua_chave>
   ```
2. No painel admin, acesse **Jogos → Adicionar jogo**, insira o ID no campo azul e clique em **"Buscar da API"** — os nomes dos times e o horário são preenchidos automaticamente.
3. Salve o jogo. A partir daí, a sincronização é automática.

### Ciclo automático

```
GoodJob (cron */10 min)
  └── SyncAllMatchResultsJob
        └── SyncMatchResultJob  (por jogo com ID cadastrado)
              └── FootballDataService → GET /matches/{id}
                    └── status FINISHED → MatchResultJob
                          ├── e-mail para vencedores (com valor do prêmio)
                          ├── e-mail para perdedores
                          └── e-mail para admins (se ninguém acertar)
```

O admin também pode acionar a sincronização manualmente pelo botão **"Sync"** na listagem de jogos, ou encerrar o jogo diretamente pela edição (útil para jogos sem ID de API).

### Rate limit

O plano gratuito permite 10 req/min. Com jogos simultâneos típicos de Copa (até 4), o cron de 10 min gera no máximo 4 chamadas por ciclo — dentro do limite.

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
- Security Group (80/443 só Cloudflare IPs, 22 aberto para GitHub Actions)
- IAM user dedicado com acesso mínimo ao S3
- Key pair SSH

### Secrets necessários no GitHub

| Secret | Descrição |
|---|---|
| `DOCKERHUB_USERNAME` | Usuário Docker Hub |
| `DOCKERHUB_TOKEN` | Token de acesso Docker Hub |
| `EC2_HOST` | Elastic IP da EC2 |
| `EC2_SSH_KEY` | Chave privada SSH (ed25519) |

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
    ├── PostgreSQL (container, volume bind em /data/postgres)
    └── GoodJob worker (mesmo container image, processo separado)
```

---

## Licença

Projeto pessoal — todos os direitos reservados.
