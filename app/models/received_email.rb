class ReceivedEmail
  include ActiveModel::Model

  attr_accessor :sender_email
  attr_accessor :headers
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :locale

  def save
    if valid?
      # UserMailer.start_decision(received_email: self).deliver_now
    else
      # send failure email
    end
  end
  alias :save! :save

  def valid?
    email_addresses.length <= Rails.application.secrets.max_pending_emails
  end

  def email_addresses
    body.scan(AppConfig::EMAIL_REGEX).uniq.reject { |email| email == self.sender_email.scan(AppConfig::EMAIL_REGEX) }
  end
end
