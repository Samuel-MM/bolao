source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Auth
gem "devise"

# Background jobs com PostgreSQL (sem Redis)
gem "good_job", "~> 4.0"

# CSS
gem "tailwindcss-rails"

# HTTP client para API Football
gem "faraday"

# PIX QR Code
gem "rqrcode"

# S3 para comprovantes de pagamento
gem "aws-sdk-s3", require: false

# Variantes de imagem no Active Storage
gem "image_processing", "~> 1.2"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
