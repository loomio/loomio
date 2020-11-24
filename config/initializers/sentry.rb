Sentry.init do |config|
  config.dsn = ENV['SENTRY_PUBLIC_DSN']
  # config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
  config.send_default_pii = true
end
