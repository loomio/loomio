class PushSubscription < ApplicationRecord
  belongs_to :user
  
  validates :endpoint, presence: true, uniqueness: { scope: :user_id }
  validates :p256dh_key, presence: true
  validates :auth_key, presence: true
end
