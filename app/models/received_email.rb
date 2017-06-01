class ReceivedEmail
  include ActiveModel::Model
  EMAIL_REGEX = /[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/

  attr_accessor :sender_email
  attr_accessor :headers
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :locale

  def save
    UserMailer.start_decision(received_email: self).deliver_now
  end
  alias :save! :save

  def email_addresses
    body.scan(EMAIL_REGEX).uniq.reject { |email| email == self.sender_email.scan(EMAIL_REGEX) }
  end
end
