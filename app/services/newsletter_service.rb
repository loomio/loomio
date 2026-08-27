class NewsletterService
  LISTMONK_URL = ENV.fetch('LISTMONK_URL', '')
  LISTMONK_USERNAME = ENV.fetch('LISTMONK_USERNAME', nil)
  LISTMONK_PASSWORD = ENV.fetch('LISTMONK_PASSWORD', nil)
  LISTMONK_LIST_ID = ENV.fetch('LISTMONK_LIST_ID', 3)

  def self.enabled?
    LISTMONK_URL.starts_with?('http') && LISTMONK_USERNAME && LISTMONK_PASSWORD && LISTMONK_LIST_ID
  end

  def self.subscribe(name, email)
    return unless enabled?

    connection.post('/api/subscribers') do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = {
        email: parse_email(email),
        name: name,
        status: 'enabled',
        lists: [ LISTMONK_LIST_ID.to_i ],
        preconfirm_subscriptions: true
      }.to_json
    end
  end

  def self.unsubscribe(email)
    return unless enabled?

    response = connection.get('/api/subscribers') do |request|
      request.params['query'] = "subscribers.email LIKE '#{parse_email(email)}'"
    end

    subscriber_id = JSON.parse(response.body).dig('data', 'results', 0, 'id').to_i

    return unless subscriber_id.positive?

    connection.delete("/api/subscribers/#{subscriber_id}")
  end

  def self.connection
    @connection ||= Faraday.new(url: LISTMONK_URL) do |faraday|
      faraday.request :authorization, :basic, LISTMONK_USERNAME, LISTMONK_PASSWORD
      faraday.request :url_encoded
      faraday.response :follow_redirects, limit: 3, clear_authorization_header: true
      faraday.adapter Faraday.default_adapter
    end
  end

  def self.parse_email(email)
    ret = email.to_s.scan(AppConfig::EMAIL_REGEX).uniq.first
    raise "invalid email #{email}" unless ret.present?
    ret
  end
end
