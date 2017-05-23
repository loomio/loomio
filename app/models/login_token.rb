class LoginToken < ActiveRecord::Base
  belongs_to :user, required: true
  has_secure_token :token
  EXPIRATION = ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 15)

  def useable?
    !used && expires_at > DateTime.now && user.present?
  end

  def expires_at
    self.created_at + EXPIRATION.minutes
  end
end
