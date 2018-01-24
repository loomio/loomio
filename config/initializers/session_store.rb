# Be sure to restart your server when you modify this file.
Loomio::Application.config.session_store :cookie_store, key: '_loomio', domain: :all, tld_length: (ENV['TLD_LENGTH'] || 1).to_i 
