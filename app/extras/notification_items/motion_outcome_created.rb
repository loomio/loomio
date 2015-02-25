class NotificationItems::MotionOutcomeCreated < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.event.user
  end

  def action_text
    I18n.t('notifications.motion_outcome_created') + ": "
  end

  def title
    @notification.eventable.name
  end

  def group_full_name
    @notification.eventable.group_full_name
  end

  def link
    Routing.motion_path(@notification.eventable)
  end
end
