class DecisionSession < ActiveRecord::Base
  has_secure_token :base_token

  def token_for(email)
    Digest::SHA1.hexdigest("#{base_token}#{email}")
  end
end
