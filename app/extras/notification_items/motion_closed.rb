class NotificationItems::MotionClosed < NotificationItem
  attr_accessor :notification


  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.event.user
  end

  def action_text
    I18n.t('notifications.motion_closed.by_expiry') + ": "
  end

  def title
    @notification.eventable.name
  end

  def linkable
    [@notification.eventable]
  end

  def avatar
    if actor
      actor
    else
      @notification.eventable.author
    end
  end
end
