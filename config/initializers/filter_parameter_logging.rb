# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :anonymous_ballot,
  :passw, :email, :secret, :token, :api_token, :webhook_secret, :registration_secret,
  :_key, :crypt, :salt, :certificate, :otp, :ssn
]
