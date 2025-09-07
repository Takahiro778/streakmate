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

  # RSpec & Testing
  gem "rspec-rails", "~> 6.1"          # RSpec本体
  gem "factory_bot_rails"              # FactoryBot
  gem "shoulda-matchers", "~> 6.0"     # モデルのバリデ/関連テスト
  gem "faker"                          # ダミーデータ生成
end

group :test do
  gem "capybara"                       # システムテスト用
  gem "selenium-webdriver"             # ブラウザ操作
  gem "database_cleaner-active_record" # DBクリーンアップ
end

# Rails & Core
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "heroicon"                         # UI用アイコン
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

# 画像処理（MiniMagick を使う）
gem "image_processing", "~> 1.2"
gem "mini_magick"

# LLM（OpenAI）
gem "ruby-openai", "~> 6.4"

# Auth / その他
gem "devise"
gem "active_hash"
gem "kaminari"
gem "rack-attack"
gem "pundit", "~> 2.5"

# AWS
gem "aws-sdk-s3", require: false
