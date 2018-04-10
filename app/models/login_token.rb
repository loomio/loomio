class LoginToken < ApplicationRecord
  belongs_to :user, required: true
  extend HasTokens

  initialized_with_token :token
  initialized_with_token :code, -> { Random.new.rand(999999) }

  EXPIRATION = ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 1440)

  def useable?
    !used && expires_at > DateTime.now && user.present?
  end

  def expires_at
    self.created_at + EXPIRATION.minutes
  end

  def user
    User.verified.find_by(email: super.email) || super
  end
end
