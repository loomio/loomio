Loomio::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true
  #EvoluteChange config.static_cache_control = 'public, max-age=31536000'
  config.static_cache_control = 'public, max-age=604800'

  # Compress JavaScripts and CSS
  config.assets.compress = true
  #NOEvoluteChange

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false
  #NOEvoluteChange

  # Generate digests for assets URLs
  config.assets.digest = true
  config.assets.enabled = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  #config.cache_store = :mem_cache_store
  config.cache_store = :dalli_store
  
  #NUDGE

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  #config.action_controller.asset_host = "d1zqv527t2wmnk.cloudfront.net"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.action_mailer.perform_deliveries = true

  # Send emails using SMTP service
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address        => ENV['SMTP_SERVER'],
    :port           => ENV['SMTP_PORT'],
    :authentication => :plain,
    :user_name      => ENV['SMTP_USERNAME'],
    :password       => ENV['SMTP_PASSWORD'],
    :domain         => ENV['SMTP_DOMAIN']
  }

  config.action_mailer.raise_delivery_errors = true


  config.action_mailer.default_url_options = {
    :host => ENV['SMTP_DOMAIN'],
  }

  # Store avatars on Amazon S3
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['S3_BUCKET_NAME'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  }
}
end
