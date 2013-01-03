# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# Use a fake secret token if we're not on production
Loomio::Application.config.secret_token = Rails.env.production? ? ENV['SECRET_COOKIE_TOKEN'] : "123456789012345678901234567890"
