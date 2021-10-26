class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] ||
                      env['action_dispatch.remote_ip'] ||
                      ip).to_s
    end
  end

  RATE_MULTIPLIER = ENV.fetch('RACK_ATTACK_RATE_MULTPLIER', 1).to_i
  TIME_MULTIPLIER = ENV.fetch('RACK_ATTACK_TIME_MULTPLIER', 1).to_i

  # throttle('req/ip', limit: 300, period: 5.minutes) do |req|
  #   req.remote_ip
  # end
  IP_POST_LIMITS = {
    '/api/v1/announcements': 100,
    '/api/v1/groups': 10,
    '/api/v1/group_surveys': 10,
    '/api/v1/login_tokens': 10,
    '/api/v1/membership_requests': 100,
    '/api/v1/memberships': 100,
    '/api/v1/identities': 10,
    '/api/v1/discussions': 100,
    '/api/v1/polls': 100,
    '/api/v1/outcomes': 100,
    '/api/v1/stances': 100,
    '/api/v1/profile': 100,
    '/api/v1/webhooks': 10,
    '/api/v1/comments': 100,
    '/api/v1/reactions': 100,
    '/api/v1/link_previews': 100,
    '/api/v1/registrations': 10,
    '/api/v1/sessions': 10,
    '/api/v1/contact_messages': 10,
    '/api/v1/contact_requests': 10,
    '/api/v1/discussion_readers': 1000,
    '/rails/active_storage/direct_uploads': 10
  }

  IP_POST_LIMITS.each_pair do |route, limit|
    throttle("post/ip/hour #{route}", limit: limit * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
      req.remote_ip if req.post? && req.path.starts_with?(route)
    end
  end

  # MAX posts per day is 3 times the posts per hour
  IP_POST_LIMITS.each_pair do |route, limit|
    throttle("post/ip/day #{route}", limit: limit * 3 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).day) do |req|
      req.remote_ip if req.post? && req.path.starts_with?(route)
    end
  end

  ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, req_h|
    req = req_h[:request]
    Rails.logger.warn [name,
                       req.remote_ip,
                       req.request_method,
                       req.fullpath,
                       request_id].join(' ')
  end
end
