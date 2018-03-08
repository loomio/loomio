class Notification < ApplicationRecord

  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :event

  validates_presence_of :user, :event
  validates_presence_of :url, unless: :persisted?
  validates_uniqueness_of :user_id, scope: :event_id

  delegate :eventable, to: :event, allow_nil: true
  delegate :kind, to: :event, allow_nil: true
  delegate :locale, to: :user
  delegate :message_channel, to: :user

  scope :user_mentions, -> { joins(:event).where("events.kind": :user_mentioned) }
end
