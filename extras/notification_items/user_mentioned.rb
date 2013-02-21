class NotificationItems::UserMentioned < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.user_mentioned')
  end

  def link
    discussion_path = url_helpers.discussion_path(@notification.eventable.discussion)
    discussion_path + "#comment-#{@notification.eventable.id}"
  end
end