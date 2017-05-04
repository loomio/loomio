class LoginToken < ActiveRecord::Base
  belongs_to :user, required: true
  has_secure_token :token

  def useable?
    !(expired? || used?)
  end

  private

  def expired?
    Time.now - self.created_at > ENV.fetch('LOGIN_TOKEN_EXPIRATION_MINUTES', 15).minutes
  end
end
