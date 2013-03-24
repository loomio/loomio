require 'awesome_print'
Loomio::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
  config.serve_static_assets = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
  config.action_mailer.file_settings = {
    :location => Rails.root.join('tmp/mail')
  }

  #fake production settings
  #config.serve_static_assets = false
  #config.assets.compress = true
  #config.assets.compile = false
  #config.assets.digest = true
  #config.assets.precompile += %w(active_admin.css active_admin.js frontpage.js frontpage.css active_admin.css)
end
