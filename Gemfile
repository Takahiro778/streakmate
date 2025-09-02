source "https://rubygems.org"
ruby "3.2.0"

# Production
group :production do
  gem "pg", "~> 1.6"
end

# Development & Test
group :development, :test do
  gem "sqlite3", "~> 1.4"
  gem "dotenv-rails", "~> 3.1"
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 6.1"   # ✅ RSpec追加
  gem "faker"
end

# Rails & Core
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem 'image_processing'

# LLM（OpenAI）
gem "ruby-openai", "~> 6.4"

# Auth
gem "devise"
gem 'active_hash'
gem "kaminari"
gem "rack-attack"

# Test-only
group :test do
  gem "capybara"
  gem "selenium-webdriver"
end