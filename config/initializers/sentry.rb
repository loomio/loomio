Sentry.init do |config|
  config.dsn = ENV['SENTRY_PUBLIC_DSN']
  config.breadcrumbs_logger = [:sentry_logger]
  config.send_default_pii = true
  config.traces_sample_rate = ENV.fetch('SENTRY_SAMPLE_RATE', 0.1).to_f
  config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', 1.0).to_f # this is relative to traces_sample_rate
end
