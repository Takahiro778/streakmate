require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Streakmate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # lib 配下の自動読み込み設定（Rails 7.1 の推奨記法）
    # assets / tasks は除外しつつ、middleware 等は対象にする
    config.autoload_lib(ignore: %w[assets tasks])

    # 本番ビルドでも確実に読み込ませるため、念のため明示追加
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # Configuration for the application, engines, and railties goes here.
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
