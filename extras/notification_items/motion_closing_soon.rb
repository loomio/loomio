class NotificationItems::MotionClosingSoon < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.motion_closing_soon') + ": "
  end

  def title
    @notification.eventable.name
  end

  def link
    url_helpers.motion_path(@notification.eventable)
  end
end