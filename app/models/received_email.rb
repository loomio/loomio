class ReceivedEmail < ApplicationRecord
  has_many_attached :attachments

  def header(name)
    self.headers.find { |key, value| key.downcase == name.to_s.downcase }&.last
  end

  def recipient_emails
    header('to').scan(AppConfig::EMAIL_REGEX).uniq
  end

  def route_address
    recipient_emails.find {|email| email.split('@')[1].downcase == ENV['REPLY_HOSTNAME']}
  end

  def route_path
    route_address.split('@')[0]
  end

  def sender_email
    header('from').scan(AppConfig::EMAIL_REGEX).uniq.first
  end

  def body
    # remember to truncate the text once you see secret split code or --
    Premailer.new(
      (body_html || body_text),
      line_length: 10000,
      with_html_string: true).to_plain_text
  end

  def subject
    header('subject')
  end

  def is_auto_response?
    return true if header('x-autorespond') || header('X-Precedence') ==  'auto_reply'

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

    return true if prefixes.any? do |prefix|
      self.subject.downcase.starts_with?(prefix.downcase)
    end

    false
  end
end
