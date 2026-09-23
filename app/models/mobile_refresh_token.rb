class MobileRefreshToken < ApplicationRecord
  belongs_to :mobile_device
  belongs_to :parent, class_name: "MobileRefreshToken", optional: true
  has_many :children, class_name: "MobileRefreshToken", foreign_key: :parent_id, dependent: :nullify

  validates :token_digest, :family_id, :expires_at, :idle_expires_at, presence: true
  validates :token_digest, uniqueness: true

  def usable?
    consumed_at.nil? && revoked_at.nil? && expires_at.future? && idle_expires_at.future? && mobile_device.active?
  end
end
