# One channel-specific delivery identity for a notification and recipient.
# delivered_at records successful channel delivery; viewed_at records in-app reading.
class NotificationDelivery < ApplicationRecord
  CHANNELS = %w[in_app email push chatbot].freeze

  belongs_to :notification
  belongs_to :recipient, polymorphic: true

  validates :channel, inclusion: { in: CHANNELS }
  validates :notification_id,
            uniqueness: { scope: %i[channel recipient_type recipient_id] }


  scope :delivered, -> { where.not(delivered_at: nil) }

  def viewed?
    viewed_at.present?
  end
end
