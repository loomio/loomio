class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :event

  validates_presence_of :user, :event

  delegate :eventable, to: :event, allow_nil: true
  delegate :kind, to: :event, allow_nil: true
  delegate :locale, to: :user
  delegate :message_channel, to: :user

  scope :dangling, -> { joins('left join events e on notifications.event_id = e.id left join users u on u.id = notifications.user_id').where('e.id is null or u.id is null') }
  scope :user_mentions, -> { joins(:event).where("events.kind": :user_mentioned) }
end
