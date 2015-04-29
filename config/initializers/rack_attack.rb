Rack::Attack.cache.store = Rails.cache
Rack::Attack.throttled_response = ->(env) { [429, {}, [ActionView::Base.new.render(file: 'public/429.html')]] }

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  Airbrake.notify Exception.new(message: "#{req.ip} has been rate limited for url #{req.url}", data: req.env['rack.attack.throttle_data'])
end

@config = YAML.load_file("#{Rails.root}/config/rack_attack.yml").with_indifferent_access

def from_config(key, field)
   @config[key][field] || @config[:default][field]
end

def throttle_request?(key, req)
  from_config(key, :method) == req.env['REQUEST_METHOD'] &&
  /#{from_config(key, :path)}/.match(req.path.to_s)
end

@config.keys.each do |key|
  Rack::Attack.throttle key, limit: from_config(key, :limit), period: from_config(key, :period) do |req|
    req.ip if throttle_request? key, req
  end unless key == 'default'
end
