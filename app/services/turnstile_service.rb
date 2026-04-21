module TurnstileService
  SITEVERIFY_URL = 'https://challenges.cloudflare.com/turnstile/v0/siteverify'.freeze
  REQUEST_TIMEOUT_SECONDS = 5

  def self.enabled?
    ENV['TURNSTILE_SECRET_KEY'].to_s.strip.length > 0
  end

  def self.site_key
    ENV['TURNSTILE_SITE_KEY']
  end

  def self.verify(token, remote_ip: nil)
    return true unless enabled?
    return false if token.to_s.strip.empty?

    response = HTTParty.post(
      SITEVERIFY_URL,
      body: { secret: ENV['TURNSTILE_SECRET_KEY'], response: token, remoteip: remote_ip }.compact,
      timeout: REQUEST_TIMEOUT_SECONDS
    )
    return false unless response.code == 200
    body = response.parsed_response
    body.is_a?(Hash) && body['success'] == true
  rescue HTTParty::Error, SocketError, Timeout::Error, Net::OpenTimeout, Net::ReadTimeout
    false
  end
end
