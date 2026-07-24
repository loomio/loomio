require 'ipaddr'

class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= begin
        addr = IPAddr.new(ip.to_s) rescue nil
        if env['HTTP_CF_CONNECTING_IP'].present? && addr && Rack::Attack::CLOUDFLARE_NETWORKS.any? { |net| net.include?(addr) }
          env['HTTP_CF_CONNECTING_IP'].to_s
        else
          (env['action_dispatch.remote_ip'] || ip).to_s
        end
      end
    end
  end

  RATE_MULTIPLIER = ENV.fetch('RACK_ATTACK_RATE_MULTIPLIER', 1).to_i

  Rails.logger.warn 'RACK_ATTACK_RATE_MULTIPLIER is greater than 1 in production' if Rails.env.production? && RATE_MULTIPLIER > 1

  CLOUDFLARE_NETWORKS = %w[
    173.245.48.0/20
    103.21.244.0/22
    103.22.200.0/22
    103.31.4.0/22
    141.101.64.0/18
    108.162.192.0/18
    190.93.240.0/20
    188.114.96.0/20
    197.234.240.0/22
    198.41.128.0/17
    162.158.0.0/15
    104.16.0.0/13
    104.24.0.0/14
    172.64.0.0/13
    131.0.72.0/22
    2400:cb00::/32
    2606:4700::/32
    2803:f800::/32
    2405:b500::/32
    2405:8100::/32
    2a06:98c0::/29
    2c0f:f248::/32
  ].map { |cidr| IPAddr.new(cidr) }.freeze

  # Exempt internal service-to-service traffic (Docker bridge, loopback,
  # RFC1918) from rate limits. Container-to-container requests have no
  # CF-Connecting-IP, so they'd otherwise share one discriminator per
  # Docker bridge address and trip global throttles quickly.
  PRIVATE_NETWORKS = %w[
    10.0.0.0/8
    172.16.0.0/12
    192.168.0.0/16
    127.0.0.0/8
  ].map { |cidr| IPAddr.new(cidr) }.freeze

  safelist('private-network') do |req|
    addr = IPAddr.new(req.ip.to_s) rescue nil
    addr && PRIVATE_NETWORKS.any? { |net| net.include?(addr) }
  end

  # Allowlist for first-party services that egress over the public internet
  # (hocuspocus auth callbacks, hakara inbound-email relay, etc). Set
  # TRUSTED_INGRESS_IPS to a comma-separated list of IPs or CIDRs.
  TRUSTED_INGRESS_IPS = ENV.fetch('TRUSTED_INGRESS_IPS', '')
                          .split(',')
                          .map(&:strip)
                          .reject(&:empty?)
                          .map { |s| IPAddr.new(s) rescue nil }
                          .compact
                          .freeze

  safelist('trusted-ingress') do |req|
    next false if TRUSTED_INGRESS_IPS.empty?
    addr = IPAddr.new(req.ip.to_s) rescue nil
    addr && TRUSTED_INGRESS_IPS.any? { |net| net.include?(addr) }
  end

  throttle('req/ip', limit: 900 * RATE_MULTIPLIER, period: 5.minutes) do |req|
    req.remote_ip unless req.path == '/bug_tunnel'
  end

  # Dedicated higher-ceiling throttle for the Sentry tunnel. A single client
  # in a JS error loop can spike bug_tunnel traffic without meaning to DoS
  # the site — give it room, but still stop runaway clients.
  throttle('bug_tunnel/ip', limit: 500 * RATE_MULTIPLIER, period: 5.minutes) do |req|
    req.remote_ip if req.path == '/bug_tunnel'
  end
  IP_POST_LIMITS = {
    '/api/v1/trials' => 10,
    '/api/v1/announcements' => 100,
    '/api/v1/groups' => 20,
    '/api/v1/templates' => 10,
    '/api/v1/login_tokens' => 50,
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
    '/api/v1/sessions' => 30,
    '/api/v1/contact_messages' => 10,
    '/api/v1/contact_requests' => 10,
    '/api/v1/discussion_readers' => 500,
    '/rails/active_storage/direct_uploads' => 20,
    # The app's real upload route (the stock path is shadowed to the same
    # controller); throttle it too or it falls through to only the global cap.
    '/direct_uploads' => 20
  }

  # Throttle only creation (POST to the exact collection path). Updates and
  # nested member actions fall through to the global req/ip limit above.
  IP_POST_LIMITS.each_pair do |route, limit|
    throttle("post/ip/hour #{route}", limit: limit * RATE_MULTIPLIER, period: 1.hour) do |req|
      req.remote_ip if req.post? && req.path == route
    end
  end

  # Per-email rate limiting on auth endpoints
  throttle("login_tokens/email", limit: 5, period: 1.hour) do |req|
    if req.post? && req.path.starts_with?('/api/v1/login_tokens')
      req.params['email'].to_s.downcase.presence
    end
  end

  throttle("sessions/email", limit: 10, period: 1.hour) do |req|
    if req.post? && req.path.starts_with?('/api/v1/sessions')
      req.params.dig('user', 'email').to_s.downcase.presence
    end
  end

  throttle("sessions/code/email", limit: 5, period: 15.minutes) do |req|
    if req.post? && req.path.starts_with?('/api/v1/sessions') && req.params.dig('user', 'code').present?
      req.params.dig('user', 'email').to_s.downcase.presence
    end
  end

  # /api/v1/profile/email_status is unauthenticated and falls through to
  # User.find_by(email:), so it's the enumeration surface. Throttle it
  # tightly and separately from the rest of /api/v1/profile/*.
  throttle("email_status/ip", limit: 20 * RATE_MULTIPLIER, period: 1.hour) do |req|
    req.remote_ip if req.get? && req.path == '/api/v1/profile/email_status'
  end

  throttle("profile_get/ip", limit: 60 * RATE_MULTIPLIER, period: 1.hour) do |req|
    req.remote_ip if req.get? && req.path.starts_with?('/api/v1/profile/') && req.path != '/api/v1/profile/email_status'
  end

  # Tight per-IP throttle for the merge verification endpoint (POST).
  # An attacker could otherwise spam this with a victim's email to flood their
  # inbox and/or rotate the source user's secret_token repeatedly.
  throttle("send_merge_verification_email/ip", limit: 5 * RATE_MULTIPLIER, period: 1.hour) do |req|
    req.remote_ip if req.post? && req.path == '/api/v1/profile/send_merge_verification_email'
  end

  ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, start, finish, request_id, req_h|
    req = req_h[:request]
    matched = req.env['rack.attack.matched']
    discriminator = req.env['rack.attack.match_discriminator']
    # bug_tunnel receives forwarded browser-side Sentry envelopes, so one
    # client in an error loop can spam it. Skip alerting on that throttle —
    # each blocked request would otherwise emit its own Sentry event.
    next if matched == 'bug_tunnel/ip'
    email = (req.params['email'] || req.params.dig('user', 'email')).to_s.downcase.presence rescue nil
    turnstile_provided = !!(req.params['turnstile_token'] || req.params.dig('user', 'turnstile_token')) rescue false
    Sentry.logger.warn("rack_attack:throttle",
      attributes: {
        matched: matched,
        discriminator: discriminator,
        method: req.request_method,
        path: req.fullpath,
        ip: req.remote_ip,
        email: email,
        turnstile: turnstile_provided
      }
    )
  end
end
