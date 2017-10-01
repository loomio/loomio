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

  {3  => 1.minute,
   10 => 1.hour,
   30 => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("#{limit}#{period}", :limit => limit, :period => period) do |req|
      req.ip if heavy.any? {|route| req.path.starts_with?(route)} && req.post?
    end
  end

  {10  => 1.minute,
   300 => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("#{limit}#{period}", :limit => limit, :period => period) do |req|
      req.ip if medium.any? {|route| req.path.starts_with?(route)} && req.post?
    end
  end
end
