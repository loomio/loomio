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
    config.active_job.queue_adapter = :delayed_job

    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.paths.add "extras", eager_load: true
    # config.autoload_paths += Dir["#{config.root}/app/forms/**/"]

    # config.middleware.use Rack::Attack
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.i18n.available_locales = # --> don't use this, make mostly empty yml files e.g. fallback.be.yml
    config.i18n.enforce_available_locales = false
    # config.i18n.fallbacks = # --> see initilizers/loomio_i18n

    # Configure the default encoding used in templates for Ruby 1.9.
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

    config.active_record.raise_in_transactional_callbacks = true

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

    config.force_ssl = ENV.has_key?('FORCE_SSL')
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
        openssl_verify_mode: 'none'
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
    config.action_dispatch.tld_length = (ENV['TLD_LENGTH'] || 1).to_i

  end
end
