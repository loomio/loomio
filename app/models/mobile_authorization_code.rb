class MobileAuthorizationCode < ApplicationRecord
  belongs_to :user

  validates :token_digest, :client_id, :redirect_uri, :code_challenge, :expires_at, presence: true
  validates :token_digest, uniqueness: true

  def usable?
    used_at.nil? && expires_at.future? && user.active_for_authentication?
  end
end
