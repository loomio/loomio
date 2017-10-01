class Rack::Attack
  heavy =  ['/api/v1/groups', '/api/v1/invitations/bulk_create']

  # considerations
  # multiple users could be using same ip address (eg coworking space)
  # does not distinguish between valid and invalid requests (eg: form validation)
  # - so we need to allow for errors and resubmits without interruption.
  # our attackers seem to create a group every 1 or 2 minutes, each with max invitations.
  # so we're mostly interested in the hour and day limits

  {10 => 1.hour,
   20 => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("groups#create", :limit => limit, :period => period) do |req|
      req.ip if heavy.any? {|route| req.path.starts_with?(route)} && req.post?
    end
  end

  medium = ['/api/v1/login_tokens',
            '/api/v1/invitations',
            '/api/v1/discussions',
            '/api/v1/polls',
            '/api/v1/stances',
            '/api/v1/comments',
            '/api/v1/reactions',
            '/api/v1/attachments',
            '/api/v1/contact_messages']

  {10    => 1.minute,
   100   => 1.hour,
   1000  => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("record#create", :limit => limit, :period => period) do |req|
      req.ip if medium.any? {|route| req.path.starts_with?(route)} && req.post?
    end
  end
end
