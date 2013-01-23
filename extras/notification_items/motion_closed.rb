class NotificationItems::MotionClosed < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.event.user
  end

  def action_text
    return I18n.t('notifications.motion_closed.by_user') if @notification.event.user
    I18n.t('notifications.motion_closed.by_expirey') + ": "
  end

  def title
    @notification.eventable.name
  end

  def link
    url_helpers.motion_path(@notification.eventable)
  end

  def avatar_url
    @notification.eventable.author.avatar_url if @notification.event.user
  end

  def avatar_initials
    @notification.eventable.author.avatar_initials if @notification.event.user
  end
end