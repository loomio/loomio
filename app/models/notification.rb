class Notification < ActiveRecord::Base

  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event
  validates_uniqueness_of :user_id, scope: :event_id
  after_create :publish_message

  delegate :kind, to: :event, prefix: :event
  delegate :eventable, to: :event

  def publish_message
    MessageChannelService.publish(NotificationSerializer.new(self).as_json, to: self.user)
  end
end
