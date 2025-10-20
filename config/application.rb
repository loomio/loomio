require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

require_relative '../lib/version'

def lmo_asset_host(path = nil)
  parts = []
  parts << (ENV['FORCE_SSL'] ? 'https://' : 'http://')
  parts << ENV['CANONICAL_HOST']
  if ENV['CANONICAL_PORT']
    parts << ':'
    parts << ENV['CANONICAL_PORT']
  end
  parts << path
  parts.compact.join('')
end

module Loomio
  class Application < Rails::Application
    config.load_defaults 6.0
    config.middleware.use Rack::Deflater
    config.middleware.use Rack::Attack
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end

    config.active_record.belongs_to_required_by_default = false

    config.force_ssl = ENV['FORCE_SSL'].present?
    config.ssl_options = { redirect: { exclude: -> request { request.path =~ /(received_emails|email_processor|up|hocuspocus)/ } } }

    config.i18n.enforce_available_locales = false
    config.i18n.fallbacks = [:en]

    config.action_controller.action_on_unpermitted_parameters = :raise

    # Enable the asset pipeline
    config.assets.enabled = true

    config.active_storage.variant_processor = :vips

    if ENV['AWS_BUCKET']
      config.active_storage.service = :amazon
    else
      config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', :local)
    end

    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.perform_deliveries = true

    if ENV['SMTP_SERVER']
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address: ENV['SMTP_SERVER'],
        port: ENV['SMTP_PORT'],
        authentication: ENV['SMTP_AUTH'],
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        domain: ENV['SMTP_DOMAIN'],
        ssl: ENV['SMTP_USE_SSL'].present?,
        openssl_verify_mode: ENV.fetch('SMTP_SSL_VERIFY_MODE', 'none') # options: none, peer, client_once, fail_if_no_peer_cert
      }.compact
    else
      config.action_mailer.delivery_method = :test
    end

    config.action_mailer.default_url_options = config.action_controller.default_url_options = {
      host:     ENV['CANONICAL_HOST'],
      port:     ENV['CANONICAL_PORT'],
      protocol: ENV['FORCE_SSL'] ? 'https' : 'http'
    }.compact

    config.action_mailer.asset_host = lmo_asset_host

    config.action_controller.include_all_helpers = false

    # expecting something like wss://hostname/cable, defaults to wss://canonical_host/cable
    config.action_cable.url = ENV['ACTION_CABLE_URL'] if ENV['ACTION_CABLE_URL']

    config.action_cable.allowed_request_origins = [ENV['CANONICAL_HOST'], 'http://localhost:8080']

    config.cache_store = :redis_cache_store, { url: (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379')) }
    config.action_dispatch.use_cookies_with_metadata = false

    if ENV['DISABLE_IPSPOOFINGCHECK']
      config.action_dispatch.ip_spoofing_check = false
    end

    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff',
      'X-Download-Options' => 'noopen',
      'X-Permitted-Cross-Domain-Policies' => 'none',
      'Referrer-Policy' => 'strict-origin-when-cross-origin'
    }

    config.active_storage.content_types_allowed_inline = %w(audio/webm video/webm image/png image/gif image/jpeg image/tiff image/vnd.adobe.photoshop image/vnd.microsoft.icon application/pdf)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.add_autoload_paths_to_load_path = false
    config.autoload_lib(ignore: %w[assets tasks])

    config.sass.quiet_deps = true
    config.sass.silence_deprecations = ['import']

  end
end
