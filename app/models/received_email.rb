class ReceivedEmail < ApplicationRecord
  has_many_attached :attachments

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

  def body
    text = if body_html.present?
      Premailer.new(body_html, line_length: 10000, with_html_string: true).to_plain_text
    else
      body_text
    end

    ReceivedEmailService.extract_reply_body(text, sender_name)
  end

  def subject
    String(header('subject')).gsub(/^( *(re|fwd?)(:| ) *)+/i, '')
  end

  def is_addressed_to_loomio?
    route_address.present?
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
end
