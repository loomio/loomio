class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      # Cloudflare stores remote IP in CF_CONNECTING_IP header
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] ||
                      env['action_dispatch.remote_ip'] ||
                      ip).to_s
    end
  end

  RATE_MULTIPLIER = ENV.fetch('RACK_ATTACK_RATE_MULTIPLIER', 1).to_i
  TIME_MULTIPLIER = ENV.fetch('RACK_ATTACK_TIME_MULTIPLIER', 1).to_i

  throttle('req/ip', limit: 300 * RATE_MULTIPLIER, period: (5 * TIME_MULTIPLIER).minutes) do |req|
    req.remote_ip
  end
  IP_POST_LIMITS = {
    '/api/v1/trials' => 10,
    '/api/v1/announcements' => 100,
    '/api/v1/groups' => 20,
    '/api/v1/templates' => 10,
    '/api/v1/login_tokens' => 10,
    '/api/v1/membership_requests' => 100,
    '/api/v1/memberships' => 100,
    '/api/v1/identities' => 10,
    '/api/v1/discussions' => 100,
    '/api/v1/polls' => 100,
    '/api/v1/outcomes' => 100,
    '/api/v1/stances' => 100,
    '/api/v1/profile' => 100,
    '/api/v1/comments' => 100,
    '/api/v1/reactions' => 100,
    '/api/v1/link_previews' => 100,
    '/api/v1/registrations' => 10,
    '/api/v1/sessions' => 10,
    '/api/v1/contact_messages' => 10,
    '/api/v1/contact_requests' => 10,
    '/api/v1/discussion_readers' => 1000,
    '/rails/active_storage/direct_uploads' => 20
  }

  IP_POST_LIMITS.each_pair do |route, limit|
    throttle("post/ip/hour #{route}", limit: limit * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
      req.remote_ip if (req.post? || req.put? || req.patch?) && req.path.starts_with?(route)
    end
  end

  # MAX posts per day is 3 times the posts per hour
  IP_POST_LIMITS.each_pair do |route, limit|
    throttle("post/ip/day #{route}", limit: limit * 3 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).day) do |req|
      req.remote_ip if (req.post? || req.put? || req.patch?) && req.path.starts_with?(route)
    end
  end

  # Per-email rate limiting on auth endpoints
  throttle("login_tokens/email", limit: 5 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
    if req.post? && req.path.starts_with?('/api/v1/login_tokens')
      req.params['email'].to_s.downcase.presence
    end
  end

  throttle("sessions/email", limit: 10 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
    if req.post? && req.path.starts_with?('/api/v1/sessions')
      req.params.dig('user', 'email').to_s.downcase.presence
    end
  end

  throttle("profile_get/ip", limit: 20 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
    req.remote_ip if req.get? && req.path.starts_with?('/api/v1/profile/')
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
