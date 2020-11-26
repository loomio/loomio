Sentry.init do |config|
  config.dsn = ENV['SENTRY_PUBLIC_DSN']
  config.breadcrumbs_logger = [:sentry_logger]
  config.send_default_pii = true
  # config.traces_sample_rate = ENV.fetch('SENTRY_SAMPLE_RATE', '0.1').to_f
end
