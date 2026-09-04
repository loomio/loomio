class MobilePushRegistration < ApplicationRecord
  belongs_to :mobile_device
  has_one :user, through: :mobile_device
  has_many :notification_deliveries, as: :recipient, dependent: :destroy

  validates :registration_id, :delivery_key_ciphertext, presence: true
  validates :registration_id, uniqueness: true
  validates :mobile_device_id, uniqueness: true

  scope :active, -> { joins(:mobile_device).merge(MobileDevice.active) }

  def active?
    mobile_device.active?
  end

  def delivery_key
    Mobile::RelayCredentialCipher.decrypt(delivery_key_ciphertext)
  end
end
