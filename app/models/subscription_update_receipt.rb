class SubscriptionUpdateReceipt < ApplicationRecord
  belongs_to :subscription, optional: true

  validates :event_id, :payload_digest, presence: true
  validates :event_id, uniqueness: true
end
