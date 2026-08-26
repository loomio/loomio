# One channel-specific attempt stream for a notification and recipient. Retries
# update this row rather than creating another delivery; future batch records
# can claim several email deliveries without changing notification identity.
class NotificationDelivery < ApplicationRecord
  CHANNELS = %w[in_app email push chatbot].freeze
  STATUSES = %w[pending claimed delivered failed cancelled].freeze

  belongs_to :notification
  belongs_to :recipient, polymorphic: true

  validates :channel, inclusion: { in: CHANNELS }
  validates :status, inclusion: { in: STATUSES }
  validates :attempt_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :notification_id,
            uniqueness: { scope: %i[channel recipient_type recipient_id] }

  scope :available, lambda {
    where(status: %w[pending failed])
      .where("available_at <= ?", Time.current)
      .where("next_attempt_at IS NULL OR next_attempt_at <= ?", Time.current)
  }

  def viewed?
    viewed_at.present?
  end
end
