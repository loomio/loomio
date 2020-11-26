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
    announcements: 10,
    groups: 10,
    group_surveys: 10,
    login_tokens: 10,
    membership_requests: 100,
    memberships: 100,
    identities: 10,
    discussions: 10,
    polls: 10,
    outcomes: 10,
    stances: 10,
    profile: 10,
    webhooks: 10,
    comments: 100,
    reactions: 100,
    registrations: 10,
    sessions: 10,
    contact_messages: 10,
    contact_requests: 10,
    discussion_readers: 1000
  }

  IP_POST_LIMITS.each_pair do |name, limit|
    throttle("post/ip/hour api/v1/#{name}", limit: limit * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).hour) do |req|
      req.remote_ip if req.post? && req.path.starts_with?("/api/v1/#{name}")
    end
  end

  # MAX posts per day is 3 times the posts per hour
  IP_POST_LIMITS.each_pair do |name, limit|
    throttle("post/ip/day api/v1/#{name}", limit: limit * 3 * RATE_MULTIPLIER, period: (1 * TIME_MULTIPLIER).day) do |req|
      req.remote_ip if req.post? && req.path.starts_with?("/api/v1/#{name}")
    end
  end

  ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, req_h|
    req = req_h[:request]
    Rails.logger.warn [name,
                       req.remote_ip,
                       req.request_method,
                       req.fullpath,
                       request_id,
                       req.user_agent.to_s.parameterize].join(' ')
  end
end
