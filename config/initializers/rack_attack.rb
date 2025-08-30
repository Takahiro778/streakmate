# Rack::Attack が内部で使うキャッシュストア（開発はメモリ / 本番はRedis等推奨）
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

# ✅ 非推奨対応: throttled_response → throttled_responder
Rack::Attack.throttled_responder = lambda do |request|
  match = request.env["rack.attack.match_data"] || {}
  [
    429,
    {
      "Content-Type" => "application/json; charset=utf-8",
      "Retry-After"  => match[:period].to_s
    },
    [{ error: "Too many requests. Please try again later." }.to_json]
  ]
end

class Rack::Attack
  # ① コメント投稿のレート制限：1分に20件（ユーザー単位 / 未ログインはIP単位）
  throttle("comments-by-user-minute", limit: 20, period: 1.minute) do |req|
    next unless req.post? && req.path.match?(%r{\A/logs/\d+/comments\z})
    uid = req.env.dig("rack.session", "warden.user.user.key")&.first&.first
    uid.presence || "ip:#{req.ip}"
  end

  # ② 連投の最小間隔：3秒に1件（より厳しいスパム抑止・任意）
  throttle("comments-by-user-3sec", limit: 1, period: 3.seconds) do |req|
    next unless req.post? && req.path.match?(%r{\A/logs/\d+/comments\z})
    uid = req.env.dig("rack.session", "warden.user.user.key")&.first&.first
    uid.presence || "ip:#{req.ip}"
  end

  # （任意）localhostを常に許可したい場合の例
  # safelist("allow-localhost") { |req| ["127.0.0.1", "::1"].include?(req.ip) }
end
