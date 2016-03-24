Loomio::Application.configure do
  config.log_level = :info
  config.action_dispatch.tld_length = (ENV['TLD_LENGTH'] || 1).to_i 

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.static_cache_control = 'public, max-age=31536000'

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  #config.assets.css_compressor = :sass
  config.assets.js_compressor = :uglifier

  # Generate digests for assets URLs
  config.assets.digest = true

  config.eager_load = true

  config.action_dispatch.x_sendfile_header = nil

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  if ENV['FORCE_SSL']
    config.force_ssl = true
  else
    config.force_ssl = false
  end

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  config.cache_store = :dalli_store,
                    (ENV["MEMCACHIER_SERVERS"] || "").split(","),
                    {:username => ENV["MEMCACHIER_USERNAME"],
                     :password => ENV["MEMCACHIER_PASSWORD"],
                     :failover => true,
                     :socket_timeout => 1.5,
                     :socket_failure_delay => 0.2
                    }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.perform_deliveries = true

  if ENV['SMTP_SERVER']
    # Send emails using SMTP service
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address        => ENV['SMTP_SERVER'],
      :port           => ENV['SMTP_PORT'],
      :authentication => (ENV['SMTP_AUTH'] || :plain).to_sym,
      :user_name      => ENV['SMTP_USERNAME'],
      :password       => ENV['SMTP_PASSWORD'],
      :domain         => ENV['SMTP_DOMAIN']
    }
  else
    # Send emails using local sendmail
    config.action_mailer.delivery_method = :sendmail
  end

  config.serve_static_files = true
  config.action_mailer.raise_delivery_errors = true
end
