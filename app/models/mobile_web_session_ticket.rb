class MobileWebSessionTicket < ApplicationRecord
  belongs_to :mobile_device

  validates :token_digest, :expires_at, presence: true
  validates :token_digest, uniqueness: true

  def usable?
    consumed_at.nil? && expires_at.future? && mobile_device.active?
  end
end
