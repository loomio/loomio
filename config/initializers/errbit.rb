if ENV['ERRBIT_KEY']
  Airbrake.configure do |config|
    config.project_key = ENV['ERRBIT_KEY']
    config.project_id = ENV['ERRBIT_KEY']
    config.host    = "https://#{ENV['ERRBIT_HOST']}"
    # config.port    = (ENV['ERRBIT_PORT'] || 80).to_i
    # config.secure  = config.port == 443
  end
end
