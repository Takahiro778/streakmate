# 本番で lib/middleware のミドルウェアを確実に読み込む
require Rails.root.join("lib/middleware/conditional_basic_auth").to_s
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # ===== Host / URL 設定 =====
  app_host = ENV["APP_HOST"].presence || ENV["RENDER_EXTERNAL_HOSTNAME"].presence || "streakmate.onrender.com"
  config.hosts << app_host if app_host.present?

  # mailer 用（Devise 等の URL 生成にも使われる）
  config.action_mailer.default_url_options = { host: app_host, protocol: "https" }
  # *_url を絶対URLにする
  Rails.application.routes.default_url_options[:host]     = app_host
  Rails.application.routes.default_url_options[:protocol] = "https"

  # Basic認証（環境変数でON/OFF）
  config.middleware.insert_before 0, Middleware::ConditionalBasicAuth

  # コード再読み込みなし / eager load
  config.enable_reloading = false
  config.eager_load = true

  # 例外時は自前のルート（/404, /500）を使う
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.action_dispatch.show_exceptions = :all
  config.exceptions_app = routes

  # アセット
  config.assets.compile = false

  # ===== Active Storage（S3 を使用）=====
  # 必要な環境変数:
  #   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION / (AWS_S3_BUCKET)
  config.active_storage.service = :amazon
  # vips が入っているのでバリアントは vips を利用（高速・省メモリ）
  config.active_storage.variant_processor = :vips

  # Force SSL
  config.force_ssl = true

  # ログ
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || "info").to_sym
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
  config.log_tags = [:request_id]

  # Mailer
  config.action_mailer.perform_caching = false

  # I18n
  config.i18n.fallbacks = true

  # Deprecations
  config.active_support.report_deprecations = false

  # スキーマのダンプを無効化
  config.active_record.dump_schema_after_migration = false

  # Healthcheck を Host Authorization から除外したい場合は下を有効化
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
