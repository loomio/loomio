class ReceivedEmail < ApplicationRecord
  has_many_attached :attachments
  belongs_to :group

  scope :unreleased, -> { where(released: false) }
  scope :released, -> { where(released: true) }

  def header(name)
    headers.find { |key, value| key.downcase == name.to_s.downcase }&.last
  end

  # The bundled Haraka relay renames sender-supplied Authentication-Results and
  # stamps its own SPF, DKIM, and DMARC results. Authentication failures are
  # delivered to Rails rather than rejected at the SMTP boundary so that DKIM
  # can authenticate legitimate mail that fails SPF after forwarding.
  #
  # Returns true only when we can positively determine that the From: domain
  # failed authentication. This prevents auto-authoring group-handle content for
  # a spoofed sender. Absent/unparseable results return false because requiring a
  # positive pass would break relays that don't stamp the header. Domains with
  # no DMARC remain inherently spoofable.
  def sender_authentication_failed?
    results = String(header('authentication-results')).downcase
    return false if results.blank?
    return true if results.include?('dmarc=fail')

    results.include?('dkim=fail') && results.include?('spf=fail')
  end

  def recipient_emails
    recipient_emails_relay.presence || recipient_emails_header
  end

  def recipient_emails_relay
    metadata = JSON.parse(String(header('harakadata')))
    return [] unless metadata.is_a?(Hash)

    Array(metadata['rcpt_to']).flat_map do |address|
      String(address).scan(AppConfig::EMAIL_REGEX)
    end.uniq
  rescue JSON::ParserError
    []
  end

  def recipient_emails_header
    String(header('to')).scan(AppConfig::EMAIL_REGEX).uniq
  end

  def route_address
    reply_hostnames = [ENV['REPLY_HOSTNAME'], ENV['OLD_REPLY_HOSTNAME']].compact
    recipient_emails.find do |email|
      reply_hostnames.include? email.split('@')[1].downcase
    end
  end

  def route_path
    route_address.split('@')[0]
  end

  def sender_hostname
    String(sender_email).split('@')[1]
  end

  def sender_email
    String(header('from')).scan(AppConfig::EMAIL_REGEX).uniq.first
  end

  def sender_name
    full_address = header('from').strip
    name = full_address.split('<').first.strip.delete('"')
    if name.present? && name != full_address
      name
    else
      nil
    end
  end

  def from
    header('from').strip
  end

  def sender_name_and_email
    if sender_name
      "\"#{sender_name}\" <#{sender_email}>"
    else
      sender_email
    end
  end

  def sent_to_notifications_address?
    recipient_emails.map(&:downcase).include?(ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS.downcase)
  end

  def body_format
    if body_html.present?
      'html'
    else
      'md'
    end
  end

  def full_body
    self.body_html.presence || self.body_text
  end

  def reply_body
    text = if body_html.present?
      ReverseMarkdown.convert(body_html, unknown_tags: :bypass).gsub("&nbsp;", " ")
    else
      body_text
    end

    ReceivedEmailService.extract_reply_body(text, sender_name)
  end

  def subject
    String(header('subject')).gsub(/^( *(re|fwd?)(:| ) *)+/i, '')
  end

  def title
    sender_name_and_email
  end

  def is_addressed_to_loomio?
    route_address.present? || sent_to_notifications_address?
  end

  def is_auto_response?
    return true if header('X-Autorespond')
    return true if header('X-Precedence') ==  'auto_reply'

    prefixes = [
      'Auto:',
      'Automatic reply',
      'Autosvar',
      'Automatisk svar',
      'Automatisch antwoord',
      'Abwesenheitsnotiz',
      'Risposta Non al computer',
      'Automatisch antwoord',
      'Auto Response',
      'Respuesta automática',
      'Fuori sede',
      'Out of Office',
      'Frånvaro',
      'Réponse automatique'
    ]

    prefixes.any? { |prefix| subject.downcase.starts_with?(prefix.downcase) }
  end

  def is_bounce?
    sender_email == ENV.fetch('BOUNCE_ADDRESS', "bounce@email-abuse.amazonses.com")
  end

  def is_complaint?
    sender_email == ENV.fetch('COMPLAINTS_ADDRESS', "complaints@email-abuse.amazonses.com")
  end

  def bounced_or_complained_address
    return nil unless attachments.first
    @bounced_or_complained_address ||= attachments.first.download.scan(AppConfig::EMAIL_REGEX).flatten.uniq.reject {|e| e.downcase == ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS.downcase }.first
  rescue ActiveStorage::FileNotFoundError
    nil
  end

  def complainer_address
    bounced_or_complained_address
  end

  def bounced_address
    bounced_or_complained_address
  end
end
