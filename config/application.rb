require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development benchmark test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Loomio
  class Application < Rails::Application

    config.generators do |g|
      g.template_engine :haml
      g.test_framework  :rspec, :fixture => false
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/extras
                                #{config.root}/app/forms
                                #{config.root}/app/jobs
                                #{config.root}/app/services)
    config.autoload_paths += Dir["#{config.root}/app/forms/**/"]

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


    # fallback_tree = LocalesHelper::FALLBACKS   # can this be done without loading the app in the wrong order?

    fallback_tree = { :'pt-PT' => :'pt-BR',
                      :zh => :'zh-TW',
                      :ca => :es    }

    config.i18n.fallbacks = [:en, fallback_tree]

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_mailer.default_url_options = {
      host: ENV['CANONICAL_HOST']
    }

    #config.roadie.url_options = {host: ENV['CANONICAL_HOST']}

    # required for heroku
    config.assets.initialize_on_precompile = false

    config.quiet_assets = true
    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
  end
end
