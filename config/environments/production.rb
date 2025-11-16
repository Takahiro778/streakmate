require "active_support/core_ext/integer/time"

# Optional: Basic認証ミドルウェア（存在する場合のみ読み込む）
begin
  require Rails.root.join("lib/middleware/conditional_basic_auth").to_s
rescue LoadError
end

Rails.application.configure do
  # ===== Host / URL =====
  app_host = ENV["APP_HOST"].presence || ENV["RENDER_EXTERNAL_HOSTNAME"].presence || "streakmate.onrender.com"
  config.hosts << app_host if app_host.present?

  # 絶対URLの既定値（OGP/メール用）
  Rails.application.routes.default_url_options[:host]     = app_host
  Rails.application.routes.default_url_options[:protocol] = "https"
  config.action_mailer.default_url_options = { host: app_host, protocol: "https" }

  # ===== Rack middleware =====
  # BASIC_AUTH_ENABLED=true のときだけ有効化（OGP検証時はOFFに）
  if ENV["BASIC_AUTH_ENABLED"] == "true"
    config.middleware.insert_before 0, Middleware::ConditionalBasicAuth
  end

  # ===== Boot behavior =====
  config.enable_reloading = false
  config.eager_load       = true

  # ===== Error handling / exceptions =====
  config.consider_all_requests_local   = false
  config.action_controller.perform_caching = true
  config.action_dispatch.show_exceptions = :all
  config.exceptions_app = routes

  # ===== Static files / assets =====
  # public/ 配下（/ogp.png など）を確実に配信
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present? || ENV["RENDER"].present?
  # アセットは事前コンパイル前提（importmap 利用）
  config.assets.compile = false

  # ===== Active Storage (S3) =====
  # 必要: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION / S3_BUCKET_NAME
  config.active_storage.service = :local
  config.active_storage.variant_processor = :vips

  # ===== Security =====
  config.force_ssl = true

  # ===== Logging =====
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || "info").to_sym
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)
  config.log_tags  = [:request_id]

  # ===== Mailer =====
  config.action_mailer.perform_caching = false
  # 配信方法は環境変数や別初期化ファイルで設定（SMTP など）

  # ===== I18n / deprecations =====
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false

  # ===== DB schema dump =====
  config.active_record.dump_schema_after_migration = false

  # （任意）Host Authorization からヘルスチェックを除外したい場合
  # config.host_authorization = { exclude: ->(req) { req.path == "/up" } }
end
