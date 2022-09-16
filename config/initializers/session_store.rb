Loomio::Application.config.session_store :cookie_store, key: '_loomio', secure: (ENV['FORCE_SSL'].to_i == 1)
