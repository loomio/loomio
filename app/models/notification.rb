class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :event

  validates_presence_of :user, :event

  delegate :eventable, to: :event, allow_nil: true
  delegate :kind, to: :event, allow_nil: true
  delegate :locale, to: :user

  scope :user_mentions, -> { joins(:event).where("events.kind": :user_mentioned) }
end
