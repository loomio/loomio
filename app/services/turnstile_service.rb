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

    response = connection.post(SITEVERIFY_URL) do |request|
      request.body = { secret: ENV['TURNSTILE_SECRET_KEY'], response: token, remoteip: remote_ip }.compact
      request.options.timeout = REQUEST_TIMEOUT_SECONDS
      request.options.open_timeout = REQUEST_TIMEOUT_SECONDS
    end
    return false unless response.status == 200
    body = JSON.parse(response.body)
    body.is_a?(Hash) && body['success'] == true
  rescue Faraday::Error, JSON::ParserError, SocketError, Timeout::Error
    false
  end

  def self.connection
    @connection ||= Faraday.new do |faraday|
      faraday.request :url_encoded
      faraday.response :follow_redirects, limit: 3, clear_authorization_header: true
      faraday.adapter Faraday.default_adapter
    end
  end
end
