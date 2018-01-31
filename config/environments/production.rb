Loomio::Application.configure do
  config.log_level = :info

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.static_cache_control = 'public, max-age=31536000'

  # Compress JavaScripts and CSS
  config.assets.compress = true

  config.assets.compile = true

  # config.assets.css_compressor = :sass
  # config.assets.js_compressor = :uglifier

  # Generate digests for assets URLs
  config.assets.digest = true

  config.eager_load = true

  config.action_dispatch.x_sendfile_header = nil

  config.cache_store = :redis_store, 'redis://localhost:6379/0/cache', expires_in: 90.minutes
  config.action_dispatch.rack_cache = {
    metastore:   'redis://localhost:6379/1/metastore',
    entitystore: 'redis://localhost:6379/1/entitystore'
  }

  config.active_support.deprecation = :notify

  config.action_mailer.perform_deliveries = true

  config.serve_static_files = true
  config.action_mailer.raise_delivery_errors = true
end
