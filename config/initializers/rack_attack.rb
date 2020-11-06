if ENV['USE_RACK_ATTACK']
  class Rack::Attack
    class Request < ::Rack::Request
      def remote_ip
        # Cloudflare stores remote IP in CF_CONNECTING_IP header
        @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] ||
                        env['action_dispatch.remote_ip'] ||
                        ip).to_s
      end
    end
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

    # throttles all posts to the above endponts
    # so we're looking at a record creation attack.
    # the objective of these rules is not to guess what normal behaviour looks like
    # and pitch abouve that.. but to identify what abusive behaviour certainly is,
    # and ensure it cannot get really really bad.

    # per hour
    GLOBAL_POST_LIMITS = {
      groups: 100,
      login_tokens: 1000,
      discussions: 100,
      polls: 100,
      outcomes: 100,
      stances: 1000,
      comments: 1000,
      reactions: 1000,
      registrations: 1000,
      sessions: 10000,
      contact_messages: 100,
      discussion_readers: 10000
    }

    IP_POST_LIMITS = {
      groups: 10,
      login_tokens: 10,
      discussions: 10,
      polls: 10,
      outcomes: 10,
      stances: 10,
      comments: 100,
      reactions: 100,
      registrations: 10,
      sessions: 10,
      contact_messages: 10,
      discussion_readers: 1000
    }

    # GLOBAL_POST_LIMITS.each_pair do |name, limit|
    #   throttle("global limit api/v1/#{name}#post", limit: limit, period: 1.hour) do |req|
    #     true if req.post? && req.path.starts_with?("/api/v1/#{name}")
    #   end
    # end

    IP_POST_LIMITS.each_pair do |name, limit|
      throttle("global limit api/v1/#{name}#post", limit: limit, period: 1.hour) do |req|
        remote_ip if req.post? && req.path.starts_with?("/api/v1/#{name}")
      end
    end
  end
end
