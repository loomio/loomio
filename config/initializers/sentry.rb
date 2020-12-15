Sentry.init do |config|
  config.dsn = ENV['SENTRY_PUBLIC_DSN']
  config.breadcrumbs_logger = [:sentry_logger]
  config.send_default_pii = true
  if ENV['SENTRY_SAMPLE_RATE']
    config.traces_sample_rate = ENV['SENTRY_SAMPLE_RATE'].to_f
  end
end
