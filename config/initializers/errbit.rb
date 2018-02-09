Airbrake.configure do |config|
  config.project_key = ENV['ERRBIT_KEY']
  config.project_id = 1337 # NB: this number is arbitrary but necessary ¯\_(ツ)_/¯
  config.host    = "https://#{ENV['ERRBIT_HOST']}"
  config.environment = ENV['RAILS_ENV']
end if ENV['ERRBIT_KEY']
