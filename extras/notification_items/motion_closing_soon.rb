class NotificationItems::MotionClosingSoon < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.motion_closing_soon') + ": "
  end

  def actor
    nil
  end

  def title
    @notification.eventable.name
  end

  def link
    Routing.motion_path(@notification.eventable)
  end

  def avatar
    @notification.eventable.author
  end
end
