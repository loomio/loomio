# Read Loomio routing fields from Action Mailbox's original MIME message. Only
# content attachments used by a published thread are copied into Active Storage.
class InboundEmailMessage
  attr_reader :inbound_email, :mail

  def initialize(inbound_email)
    @inbound_email = inbound_email
    @mail = inbound_email.mail
  end

  def header(name)
    Array(mail[name]).last&.decoded
  end

  def sender_email
    mail.from&.first
  end

  def sender_hostname
    sender_email.to_s.split('@').last
  end

  def sender_name
    mail[:from]&.display_names&.first.presence
  end

  def from
    header('from')
  end

  def sender_name_and_email
    from
  end

  def subject
    mail.subject.to_s.gsub(/^( *(re|fwd?)(:| ) *)+/i, '')
  end

  def sender_authentication_failed?
    results = header('authentication-results').to_s.downcase
    results.include?('dmarc=fail') || (results.include?('dkim=fail') && results.include?('spf=fail'))
  end

  def recipient_emails
    recipient_emails_relay.presence || Array(mail.to)
  end

  def recipient_emails_relay
    metadata = JSON.parse(header('harakadata').to_s)
    return [] unless metadata.is_a?(Hash)

    Array(metadata['rcpt_to']).flat_map { |address| address.to_s.scan(AppConfig::EMAIL_REGEX) }.uniq
  rescue JSON::ParserError
    []
  end

  def route_address
    hostnames = ENV.values_at('REPLY_HOSTNAME', 'OLD_REPLY_HOSTNAME').compact.map(&:downcase)
    recipient_emails.find { |address| hostnames.include?(address.split('@').last.downcase) }
  end

  def route_path
    route_address.split('@').first
  end

  def sent_to_notifications_address?
    recipient_emails.any? { |address| address.casecmp?(ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS) }
  end

  def is_addressed_to_loomio?
    route_address.present? || sent_to_notifications_address?
  end

  def is_auto_response?
    return true if header('X-Autorespond') || header('X-Precedence') == 'auto_reply'

    ['Auto:', 'Autosvar', 'Automatisk svar', 'Automatisch antwoord', 'Abwesenheitsnotiz'].any? { |prefix| subject.downcase.start_with?(prefix.downcase) } ||
      ['Automatic reply', 'Automatisch antwoord', 'Risposta Non al computer', 'Auto Response',
       'Respuesta automática', 'Fuori sede', 'Out of Office', 'Frånvaro', 'Réponse automatique'].any? do |prefix|
        subject.downcase.start_with?(prefix.downcase)
      end
  end

  def is_bounce?
    sender_email.to_s.casecmp?(ENV.fetch('BOUNCE_ADDRESS', 'bounce@email-abuse.amazonses.com'))
  end

  def is_complaint?
    sender_email.to_s.casecmp?(ENV.fetch('COMPLAINTS_ADDRESS', 'complaints@email-abuse.amazonses.com'))
  end

  def body_text
    (mail.text_part || (mail unless mail.multipart? || mail.mime_type == 'text/html'))&.decoded.to_s
  end

  def body_html
    part = mail.html_part || (mail if mail.mime_type == 'text/html')
    part&.decoded
  end

  def body_format
    body_html.present? ? 'html' : 'md'
  end

  def full_body
    return body_text if body_html.blank?

    html = body_html.dup
    attachments.each do |part, blob|
      next unless part.inline? && part.cid.present?

      url = Rails.application.routes.url_helpers.rails_blob_path(blob, only_path: true)
      html.gsub!("cid:#{part.cid.delete('<>')}", url)
    end
    html
  end

  def reply_body
    text = if body_html.present?
      ReverseMarkdown.convert(full_body, unknown_tags: :bypass).gsub('&nbsp;', ' ')
    else
      body_text
    end
    InboundEmailService.extract_reply_body(text, sender_name)
  end

  def files
    attachments.map(&:last)
  end

  private

  def attachments
    @attachments ||= mail.attachments.each_with_index.map do |part, index|
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(part.decoded.b),
        filename: part.filename.presence || part.cid.presence || "attachment-#{index + 1}",
        content_type: part.mime_type, identify: false)
      [part, blob]
    end
  end
end
