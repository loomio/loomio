# Be sure to restart your server when you modify this file.
if ENV[:NO_COOKIES_DOMAIN_ALL]
  Loomio::Application.config.session_store :cookie_store, key: '_loomio'
else
  Loomio::Application.config.session_store :cookie_store, key: '_loomio', domain: :all
end
