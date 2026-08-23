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
  # one interface. A notification's subject occupies the itemable slot without
  # making Notification itself pretend to be a timeline record.
  def itemable
    notification.subject
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
    notification.subject_type
  end

  delegate :recipient_message, to: :notification

  def notification_url
    notification.notification_url
  end
end
