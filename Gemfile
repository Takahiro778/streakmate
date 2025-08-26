source "https://rubygems.org"

ruby "3.2.0"

# productionだけpg
group :production do
  gem "pg", "~> 1.6"
end

# dev/testはsqlite3 + dotenv/debug
group :development, :test do
  gem "sqlite3", "~> 1.4"
  gem "dotenv-rails", "~> 3.1"
  gem "debug", platforms: %i[mri windows]
end

# Rails本体
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

# アセットパイプライン
gem "sprockets-rails"

# サーバ
gem "puma", ">= 5.0"

# フロントまわり
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# JSON API
gem "jbuilder"

# Windows用
gem "tzinfo-data", platforms: %i[windows jruby]

# 起動高速化
gem "bootsnap", require: false

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
