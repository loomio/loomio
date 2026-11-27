Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN'] || ENV['SENTRY_PUBLIC_DSN']
  config.breadcrumbs_logger = [:sentry_logger]
  config.send_default_pii = true
  config.traces_sample_rate = ENV.fetch('SENTRY_SAMPLE_RATE', 0.05).to_f
  config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', 1.0).to_f # this is relative to traces_sample_rate
  # SDK 7 always enables logs; opt in to forwarding them separately from errors.
  config.rails.structured_logging.enabled = ENV["SENTRY_ENABLE_LOGS"].present?
  config.before_send_log = ->(log) { ENV["SENTRY_ENABLE_LOGS"].present? && %i[warn error fatal].include?(log.level) ? log : nil }
end

# Rails 8.2 (rails/rails#50979) calls handle_open and handle_close publicly from
# ActionCable::Server::Socket, but sentry-rails prepends them as private methods.
# Remove once getsentry/sentry-ruby#2972 is released.
ActiveSupport.on_load(:action_cable_connection) do
  if defined?(Sentry::Rails::ActionCableExtensions::Connection)
    Sentry::Rails::ActionCableExtensions::Connection.module_eval do
      public :handle_open, :handle_close
    end
  end
end
