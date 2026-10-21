# One channel-specific delivery identity for a notification and recipient.
# delivered_at records successful channel delivery; viewed_at records in-app reading.
class NotificationDelivery < ApplicationRecord
  CHANNELS = %w[in_app email push chatbot].freeze

  belongs_to :notification
  belongs_to :recipient, polymorphic: true
  has_many :events, class_name: 'NotificationDeliveryEvent', dependent: :delete_all

  validates :channel, inclusion: { in: CHANNELS }
  validates :notification_id,
            uniqueness: { scope: %i[channel recipient_type recipient_id] }


  scope :delivered, -> { where.not(delivered_at: nil) }

  def viewed?
    viewed_at.present?
  end

  def email_status
    events.max_by { |event| [event.occurred_at, event.id] }&.kind || (delivered_at ? 'sent' : 'pending')
  end
end
