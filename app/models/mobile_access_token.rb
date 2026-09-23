class MobileAccessToken < ApplicationRecord
  belongs_to :mobile_device

  validates :token_digest, :scopes, :expires_at, presence: true
  validates :token_digest, uniqueness: true

  def usable?
    revoked_at.nil? && expires_at.future? && mobile_device.active?
  end

  def allows_scope?(scope)
    scopes.split.include?(scope)
  end
end
