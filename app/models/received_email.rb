class ReceivedEmail < ActiveRecord::Base
  has_secure_token

  EMAIL_REGEX = /[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/

  validates :sender_email, presence: true

  attr_accessor :subject

  def locale
    :en
  end

  def email_addresses
    body.scan(EMAIL_REGEX).uniq.reject { |email| email == self.sender_email.scan(EMAIL_REGEX) }
  end
end
