# lib/middleware/conditional_basic_auth.rb
require "digest"

class ConditionalBasicAuth
  def initialize(app); @app = app; end

  def call(env)
    return @app.call(env) unless ENV["BASIC_AUTH_ENABLED"] == "true"
    req = Rack::Request.new(env)
    return @app.call(env) if skip_path?(req.path)

    auth = Rack::Auth::Basic::Request.new(env)
    if auth.provided? && auth.basic? &&
       secure_compare(auth.credentials[0], ENV.fetch("BASIC_AUTH_USER", "")) &&
       secure_compare(auth.credentials[1], ENV.fetch("BASIC_AUTH_PASS", ""))
      @app.call(env)
    else
      [401, {"Content-Type"=>"text/plain","WWW-Authenticate"=>'Basic realm="Staging"'}, ["Unauthorized"]]
    end
  end

  private

  def skip_path?(path)
    path.start_with?("/up", "/assets", "/packs", "/rails/active_storage")
  end

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(a.to_s),
      ::Digest::SHA256.hexdigest(b.to_s)
    )
  end
end
