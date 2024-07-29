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

    HTTParty.post(
      "#{LISTMONK_URL}/api/subscribers",
      {
        basic_auth: auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          email: parse_email(email),
          name: name,
          status: 'enabled',
          lists: [LISTMONK_LIST_ID.to_i],
          preconfirm_subscriptions: true,
        }.to_json,
        # :debug_output => $stdout
      }
    )
  end

  def self.unsubscribe(email)
    return unless enabled?

    response = HTTParty.get(
      "#{LISTMONK_URL}/api/subscribers",
      basic_auth: auth,
      query: {
        query: "subscribers.email LIKE '#{parse_email(email)}'"
      }
    )

    subscriber_id = response.dig('data', 'results', 0, 'id')

    return unless subscriber_id.present?

    HTTParty.delete(
      "#{LISTMONK_URL}/api/subscribers/#{subscriber_id}",
      basic_auth: auth
    )
  end

  def self.auth
    {username: LISTMONK_USERNAME, password: LISTMONK_PASSWORD}
  end

  def self.parse_email(email)
    ret = email.to_s.scan(AppConfig::EMAIL_REGEX).uniq.first
    raise "invalid email #{email}" unless ret.present?
    ret
  end
end
