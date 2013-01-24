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
    return I18n.t('notifications.motion_closed.by_user') if actor
    I18n.t('notifications.motion_closed.by_expirey') + ": "
  end

  def title
    @notification.eventable.name
  end

  def link
    url_helpers.motion_path(@notification.eventable)
  end

  def avatar_url
    return actor.avatar_url(:medium) if actor
    @notification.eventable.author.avatar_url(:medium)
  end

  def avatar_initials
    return actor.avatar_initials if actor
    @notification.eventable.author.avatar_initials
  end
end