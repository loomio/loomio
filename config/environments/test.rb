Loomio::Application.configure do
  config.cache_classes = true
  config.serve_static_files = true

  # Log error messages when you accidentally call methods on nil
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  config.action_controller.action_on_unpermitted_parameters = :raise

  config.eager_load = false

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.action_mailer.raise_delivery_errors = true
  config.middleware.use RackSessionAccess::Middleware

  # Turns off logging for test environment, 6% speed up for testsuit
  config.logger = Logger.new(nil)
  config.log_level = :fatal
end
