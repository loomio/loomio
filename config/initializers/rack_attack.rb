class Rack::Attack
  heavy =  ['/api/v1/groups', '/api/v1/invitations/bulk_create']

  # considerations
  # multiple users could be using same ip address (eg coworking space)
  # does not distinguish between valid and invalid requests (eg: form validation)
  # - so we need to allow for errors and resubmits without interruption.
  # our attackers seem to create a group every 1 or 2 minutes, each with max invitations.
  # so we're mostly interested in the hour and day limits

  # group creation and invitation sending is the most common attack we see
  # usually we get a few new groups per hour, globally.
  # when attacks happen we see a few groups per minute, usually with the same name
  # each trying to invite max_invitations with bulk create.

  {10 => 1.hour,
   20 => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("groups#create", :limit => limit, :period => period) do |req|
      req.ip if heavy.any? {|route| req.path.starts_with?(route)} && req.post?
    end
  end unless Rails.env.test?

  medium = ['login_tokens',
            'invitations',
            'discussions',
            'polls',
            'stances',
            'comments',
            'reactions',
            'documents',
            'registrations',
            'contact_messages']

  # throttles all posts to the above endponts
  # so we're looking at a record creation attack.
  # the objective of these rules is not to guess what normal behaviour looks like
  # and pitch abouve that.. but to identify what abusive behaviour certainly is,
  # and ensure it cannot get really really bad.
  {100     => 5.minutes,
   1000    => 1.hour,
   10000   => 1.day}.each_pair do |limit, period|
    Rack::Attack.throttle("record#create", :limit => limit, :period => period) do |req|
      req.ip if medium.any? {|route| req.path.starts_with?("/api/v1/#{route}")} && req.post?
    end
  end unless Rails.env.test?
end
