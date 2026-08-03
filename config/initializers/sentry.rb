Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN'] || ENV['SENTRY_PUBLIC_DSN']
  config.breadcrumbs_logger = [:sentry_logger]
  config.send_default_pii = true
  config.traces_sample_rate = ENV.fetch('SENTRY_SAMPLE_RATE', 0.1).to_f
  config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', 1.0).to_f # this is relative to traces_sample_rate
  config.enable_logs = ENV["SENTRY_ENABLE_LOGS"].present?
  config.before_send_log = lambda do |log|
    audit_kind = log.attributes['audit_kind'] || log.attributes[:audit_kind]
    log if %i[warn error fatal].include?(log.level) || audit_kind == 'translation_api'
  end
end
