class LoginToken < ActiveRecord::Base
  belongs_to :user, required: true
  has_secure_token :token
  EXPIRATION = ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 15)

  scope :useable, -> { where(used: false).where('created_at > ?', EXPIRATION.minutes.ago) }

  def expires_at
    self.created_at + EXPIRATION.minutes
  end
end
