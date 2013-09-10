class NotificationItems::MotionClosed < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.event.eventable.author
  end

  def action_text
    return I18n.t('notifications.motion_closed.by_user') if actor
    I18n.t('notifications.motion_closed.by_expiry') + ": "
  end

  def title
    @notification.eventable.name
  end

  def link
    url_helpers.motion_path(@notification.eventable)
  end

  def avatar
    return actor if actor
    @notification.eventable.author
  end
end
