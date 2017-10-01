class Rack::Attack
  heavy =  ['/api/v1/groups']

  medium = ['/api/v1/login_tokens',
            '/api/v1/invitations',
            '/api/v1/discussions',
            '/api/v1/polls',
            '/api/v1/stances',
            '/api/v1/comments',
            '/api/v1/reactions',
            '/api/v1/attachments',
            '/api/v1/contact_messages']

  # heavy throttling - 3 per minute, 10 per hour, 50 per day
  Rack::Attack.throttle('heavy/minute', :limit => 3, :period => 1.minute) do |req|
    heavy.any? {|route| req.path.starts_with?(route)} && req.post?
  end

  Rack::Attack.throttle('heavy/hour', :limit => 10, :period => 1.hour) do |req|
    heavy.any? {|route| req.path.starts_with?(route)} && req.post?
  end

  Rack::Attack.throttle('heavy/day', :limit => 50, :period => 1.day) do |req|
    heavy.any? {|route| req.path.starts_with?(route)} && req.post?
  end

  # medium 10 per minute, 300 per day
  Rack::Attack.throttle('medium/minute', :limit => 10, :period => 1.minute) do |req|
    medium.any? {|route| req.path.starts_with?(route)} && req.post?
  end

  Rack::Attack.throttle('medium/day', :limit => 300, :period => 1.day) do |req|
    medium.any? {|route| req.path.starts_with?(route)} && req.post?
  end
end
