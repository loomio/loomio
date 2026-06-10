class LoginToken < ApplicationRecord
  belongs_to :user, required: true
  extend HasTokens

  initialized_with_token :token
  initialized_with_token :code, -> { generate_code }

  EXPIRATION = ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 60).to_i
  MAX_FAILED_CODE_ATTEMPTS = 5

  scope :unused, -> { where(used: false) }

  def useable?
    !used && failed_attempts < MAX_FAILED_CODE_ATTEMPTS && expires_at > DateTime.now && user.present?
  end

  def record_failed_code_attempt!
    increment!(:failed_attempts)
    update!(used: true) if failed_attempts >= MAX_FAILED_CODE_ATTEMPTS
  end

  def expires_at
    self.created_at + EXPIRATION.minutes
  end

  def user
    User.verified.find_by(email: super.email) || super
  end

  def self.generate_code
    SecureRandom.random_number(100000..999999)
  end
end
