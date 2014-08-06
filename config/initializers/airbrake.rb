Airbrake.configure do |config|
  config.api_key = Rails.application.secrets.airbrake_api_key
end
