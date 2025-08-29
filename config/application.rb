require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Streakmate
  class Application < Rails::Application
    config.load_defaults 7.1

    # lib 配下の自動読み込み設定（Rails 7.1 の推奨記法）
    config.autoload_lib(ignore: %w[assets tasks])

    # 本番ビルドでも確実に読み込ませるため、念のため明示追加
    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    # ✅ タイムゾーンを日本（東京）に設定
    config.time_zone = "Asia/Tokyo"
    config.active_record.default_timezone = :local

    # ✅ Rack::Attack（レート制限/濫用対策）をミドルウェアとして有効化
    config.middleware.use Rack::Attack

    # Configuration for the application, engines, and railties goes here.
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
