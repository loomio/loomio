class ReceivedEmail
  include ActiveModel::Model

  attr_accessor :sender_email
  attr_accessor :headers
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :locale
  attr_accessor :json

  def from_mailin(params)
    new(sender_email: params.dig('from', 0, 'address'),
        headers:      params['headers'],
        subject:      params.dig('headers', 'subject'),
        body:         params['html'] || mailin_params['text'],
        locale:       params['language'],
        receiving_email: params.to.find{|contact| contact['address'].ends_with?(ENV['REPLY_HOSTNAME'])}&.dig('address')
        json:         params)
  end

  email_hash = email.to.select{|h| h[:host] == reply_host }.first || {}
  params = {}

  email_hash[:token].to_s.split('&').each do |segment|
    key_and_value = segment.split('=')
    params[key_and_value[0]] = key_and_value[1]
  end

  @discussion_id = params['d']
  @user_id       = params['u']
  @parent_id     = params['c']
  @email_api_key = params['k']
  @body          = email.body


  def valid?
    email_addresses.length <= Rails.application.secrets.max_pending_emails
    recipient_address finishes with the reply_hostname
  end

  def email_addresses
    body.scan(AppConfig::EMAIL_REGEX).uniq.reject { |email| email == self.sender_email.scan(AppConfig::EMAIL_REGEX) }
  end

  def receiving_address
    json.to.find{|contact| contact['address'].ends_with?(ENV['REPLY_HOSTNAME'])}
  end
end
