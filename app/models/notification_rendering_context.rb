# Shared rendering interface for notification-backed mail and chatbot delivery.
# It exposes the subject and actor without manufacturing a persisted topic item.
class NotificationRenderingContext
  attr_reader :notification

  delegate :id, :kind, to: :notification

  def initialize(notification)
    @notification = notification
  end

  def user
    notification.actor || AnonymousUser.new
  end

  alias actor user

  # Mail and chatbot views render topic publications and notifications through
  # one interface. TopicItem subjects unwrap to their itemable while operational
  # notification subjects are already domain records.
  def itemable
    notification.subject_model
  end

  def group
    itemable.group if itemable.respond_to?(:group)
  end

  def poll
    itemable.poll if itemable.respond_to?(:poll)
  end

  def topic
    itemable.topic if itemable.respond_to?(:topic)
  end

  def itemable_type
    itemable.class.base_class.name
  end

  delegate :recipient_message, to: :notification

  def notification_url
    notification.notification_url
  end
end
