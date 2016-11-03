class Notification < ActiveRecord::Base

  belongs_to :user
  belongs_to :actor, class_name: 'User'
  belongs_to :event

  validates_presence_of :user, :event
  validates_presence_of :url, unless: :persisted?
  validates_uniqueness_of :user_id, scope: :event_id
  after_create :publish_message

  delegate :kind, to: :event
  delegate :eventable, to: :event

  scope :user_mentions, -> { joins(:event).where("events.kind": :user_mentioned) }

  def baked?
    url.present? && translation_values.present?
  end

  def bake!(persist: true)
    assign_attributes(event.notification_attributes).tap { save! if persist }
  end

  def publish_message
    MessageChannelService.publish(NotificationSerializer.new(self).as_json, to: self.user)
  end
end
