class Rack::Attack
  throttle("comments-by-user-minute", limit: 20, period: 1.minute) do |req|
    next unless req.post? && req.path.match?(%r{\A/logs/\d+/comments\z})
    uid = req.env["rack.session"]&.dig("warden.user.user.key")&.first&.first
    uid.presence || "ip:#{req.ip}"
  end
end
