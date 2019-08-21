# Be sure to restart your server when you modify this file.
Loomio::Application.config.session_store :cookie_store, key: '_loomio', domain: ENV.fetch('SESSION_DOMAIN', ENV['CANONICAL_HOST']), secure: (ENV['FORCE_SSL'].to_i == 1)
