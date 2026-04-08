class LoginToken < ApplicationRecord
  belongs_to :user, required: true
  extend HasTokens

  initialized_with_token :token
  initialized_with_token :code, -> { generate_code }

  EXPIRATION = ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 60).to_i

  scope :unused, -> { where(used: false) }

  def useable?
    !used && expires_at > DateTime.now && user.present?
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
