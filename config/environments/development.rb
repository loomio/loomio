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
  config.sass.line_comments = false

  config.eager_load = false

  config.action_controller.action_on_unpermitted_parameters = :raise
  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.bullet_logger = true
  #   Bullet.console = true
  #   Bullet.rails_logger = true
  #   # Bullet.add_footer = true
  # end
end
