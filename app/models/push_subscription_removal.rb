class PushSubscriptionRemoval < ApplicationRecord
  belongs_to :user

  validates :endpoint_digest, presence: true, uniqueness: { scope: :user_id }
end
