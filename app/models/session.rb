class Session < ApplicationRecord
  belongs_to :user
  has_many :push_subscriptions, dependent: :destroy
end
