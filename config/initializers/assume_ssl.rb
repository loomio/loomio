class AssumeSSL
  def initialize(app)
    @app = app
  end

  def call(env)
    env["HTTPS"] = "on"
    env["HTTP_X_FORWARDED_PORT"] = 443
    env["HTTP_X_FORWARDED_PROTO"] = "https"
    env["rack.url_scheme"] = "https"

    @app.call(env)
  end
end

# TODO: delete this file once we're on Rails 7.1
Rails.application.config.middleware.insert_before(0, AssumeSSL) if ENV['ASSUME_SSL']