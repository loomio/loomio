Loomio::Application.configure do
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.raise_runtime_errors = true
  config.assets.raise_production_errors = true
  config.sass.debug_info = true

  # support scss support in chrome devtools
  #
  config.sass.line_comments = false

  # config.action_mailer.asset_host = "http://localhost:3000"
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }

  config.eager_load = false
  config.roadie.url_options = {host: 'localhost'}

  # Use these settings to send mail from gmail. If you use 2-step authentication on
  # your google account, create a new application-specific password and use it in here
  # http://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration-for-gmail
  #
  # config.action_mailer.smtp_settings = {
  #   address:              'smtp.gmail.com',
  #   port:                 587,
  #   domain:               'example.com',
  #   user_name:            ENV['GMAIL_USER_NAME'],
  #   password:             ENV['GMAIL_PASSWORD'],
  #   authentication:       'plain',
  #   enable_starttls_auto: true
  # }

  config.action_mailer.file_settings = {
    :location => Rails.root.join('tmp/mail')
  }

  config.action_controller.action_on_unpermitted_parameters = :raise
end
