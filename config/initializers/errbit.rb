if false #ENV['ERRBIT_KEY']
  Airbrake.configure do |config|
    config.api_key = ENV['ERRBIT_KEY']
    config.host    = ENV['ERRBIT_HOST']
    config.port    = (ENV['ERRBIT_PORT'] || 80).to_i
    config.secure  = config.port == 443
  end
end
