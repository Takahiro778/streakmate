# 本番で lib/middleware のミドルウェアを確実に読み込む
require Rails.root.join("lib/middleware/conditional_basic_auth").to_s
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Renderのホスト許可
  config.hosts << ENV["RENDER_EXTERNAL_HOSTNAME"] if ENV["RENDER_EXTERNAL_HOSTNAME"].present?

  # ===== ここから追加：URLヘルパの絶対URL化 =====
  app_host = ENV["APP_HOST"].presence || ENV["RENDER_EXTERNAL_HOSTNAME"].presence || "streakmate.onrender.com"
  # mailer 用（Devise等のURL生成にも使われる）
  config.action_mailer.default_url_options = { host: app_host, protocol: "https" }
  # ルーティングの *_url が絶対URLになる
  Rails.application.routes.default_url_options[:host]     = app_host
  Rails.application.routes.default_url_options[:protocol] = "https"
  # ===== 追加ここまで =====

  # Basic認証（本番限定・環境変数でON/OFF）
  config.middleware.insert_before 0, Middleware::ConditionalBasicAuth

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Store uploaded files on the local file system.
  config.active_storage.service = :local

  # Force SSL
  config.force_ssl = true

  # Log to STDOUT by default
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Log level
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Mailer
  config.action_mailer.perform_caching = false

  # I18n fallbacks
  config.i18n.fallbacks = true

  # Deprecations
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Healthcheck を Host Authorization から除外したい場合は下を有効化
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
