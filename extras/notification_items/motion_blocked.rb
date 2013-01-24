class NotificationItems::MotionBlocked < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.motion_blocked')
  end

  def title
    @notification.eventable.motion.name
  end

  def link
    discussion_path = url_helpers.discussion_path(@notification.eventable.discussion)
    discussion_path + "?proposal=#{@notification.eventable.motion.id}"
  end
end