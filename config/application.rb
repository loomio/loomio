require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

require_relative '../lib/version'

def lmo_asset_host
  parts = []
  parts << (ENV['FORCE_SSL'] ? 'https://' : 'http://')
  parts << ENV['CANONICAL_HOST']
  if ENV['CANONICAL_PORT']
    parts << ':'
    parts << ENV['CANONICAL_PORT']
  end
  parts.join('')
end

module Loomio
  class Application < Rails::Application
    # config.load_defaults 6.0
    # config.autoloader = :classic
    config.middleware.use Rack::Attack
    # config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end

    config.active_record.belongs_to_required_by_default = false

    config.force_ssl = Rails.env.production?
    config.ssl_options = { redirect: { exclude: -> request { request.path =~ /(received_emails|email_processor)/ } } }

    config.i18n.enforce_available_locales = false
    config.i18n.fallbacks = [:en] # --> see initilizers/loomio_i18n
    config.assets.quiet = true

    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.4'

    # required for heroku
    config.assets.initialize_on_precompile = false

    config.quiet_assets = true
    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

    config.active_storage.variant_processor = :vips

    if ENV['AWS_BUCKET']
      config.active_storage.service = :amazon
    else
      config.active_storage.service = :local
    end

    # we plan to remove fog and paperclip once we've migrated to active storage
    if ENV['FOG_PROVIDER']
      def self.fog_credentials
        env = Rails.application.secrets
        case env.fog_provider
        when 'AWS'   then { aws_access_key_id: env.aws_access_key_id, aws_secret_access_key: env.aws_secret_access_key }
        when 'Local' then { local_root: [Rails.root, 'public'].join('/'), endpoint: env.canonical_host }
        end.merge(provider: env.fog_provider)
      end

      # Store avatars on Amazon S3
      config.paperclip_defaults = {
        storage: :fog,
        fog_credentials: fog_credentials,
        fog_directory: Rails.application.secrets.fog_uploads_directory,
        fog_public: true
      }
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
        ssl: ENV['SMTP_USE_SSL'],
        openssl_verify_mode: ENV.fetch('SMTP_SSL_VERIFY_MODE', 'none') # options: none, peer, client_once, fail_if_no_peer_cert
      }.compact
    else
      config.action_mailer.delivery_method = :test
    end

    port = ENV['CANONICAL_PORT']
    port = 3000 if Rails.env.development? or Rails.env.test?
    port = 8080 if ENV['USE_VUE']

    config.action_mailer.default_url_options = config.action_controller.default_url_options = {
      host:     ENV['CANONICAL_HOST'],
      port:     port,
      protocol: ENV['FORCE_SSL'] ? 'https' : 'http'
    }.compact

    config.action_mailer.asset_host = lmo_asset_host

    config.action_controller.include_all_helpers = false

    # expecting something like wss://hostname/cable, defaults to wss://canonical_host/cable
    config.action_cable.url = ENV['ACTION_CABLE_URL'] if ENV['ACTION_CABLE_URL']

    config.action_cable.allowed_request_origins = [ENV['CANONICAL_HOST'], 'http://localhost:8080']

    config.cache_store = :redis_cache_store, { url: (ENV['REDIS_CACHE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379')) }
    config.action_dispatch.use_cookies_with_metadata = false

    config.action_dispatch.default_headers = {
      # 'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff',
      'X-Download-Options' => 'noopen',
      'X-Permitted-Cross-Domain-Policies' => 'none',
      'Referrer-Policy' => 'strict-origin-when-cross-origin'
    }
  end
end
