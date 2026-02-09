class ReceivedEmail < ApplicationRecord
  has_many_attached :attachments
  belongs_to :group

  scope :unreleased, -> { where(released: false) }
  scope :released, -> { where(released: true) }

  def header(name)
    headers.find { |key, value| key.downcase == name.to_s.downcase }&.last
  end

  def recipient_emails
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

  def is_complaint?
    sender_email == ENV.fetch('COMPLAINTS_ADDRESS', "complaints@email-abuse.amazonses.com")
  end

  def complainer_address
    return nil unless attachments.first
    @complainer_address ||= attachments.first.download.scan(AppConfig::EMAIL_REGEX).flatten.uniq.reject {|e| e.downcase == ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS.downcase }.first
  rescue ActiveStorage::FileNotFoundError
    nil
  end
end
