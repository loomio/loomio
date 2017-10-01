class Rack::Attack
  # Throttle group create
  Rack::Attack.throttle('req/ip', :limit => 10, :period => 1.hour) do |req|
    req.path == '/api/v1/groups' && req.post?
  end
end
