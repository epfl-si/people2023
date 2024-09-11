# frozen_string_literal: true

class SpyMiddleware
  PATHSKIP_RE = %r{/(rails/|assets|path_to_skip)}

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    spy(env)
    [status, headers, response]
  end

  def spy(env)
    req = Rack::Request.new env
    return if req.path =~ PATHSKIP_RE

    route = Rails.application.routes.recognize_path(req.path)
    report = {
      'time' => Time.zone.now.strftime('%Y%m%d-%H%M-%s'),
      'user' => user(req),
      'path' => req.path,
      'params' => req.params,
      'route' => route,
    }
    Rails.logger.debug("=== #{report.to_yaml}")
  end

  def user(req)
    u = req.env['warden'].user
    u.nil? ? "NO AUTH" : u.slice(:sciper, :name, :email, :provider).to_h
  end
end
