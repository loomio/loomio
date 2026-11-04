# Provider feedback is an occurrence, not a replacement for the send timestamp.
# Its source key makes repeated receipt of the same report harmless.
class NotificationDeliveryEvent < ApplicationRecord
  KINDS = %w[sent delivered delayed rejected bounced complained skipped].freeze
  belongs_to :notification_delivery
  validates :bounce_type, inclusion: { in: %w[Permanent Transient Undetermined] }, allow_nil: true
  validates :kind, inclusion: { in: KINDS }
  validates :source_key, :occurred_at, presence: true
end
