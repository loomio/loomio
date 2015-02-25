class NotificationItems::UserMentioned < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.user_mentioned')
  end

  def link
    discussion_path = Routing.discussion_path(@notification.eventable.discussion)
    discussion_path + "#comment-#{@notification.eventable.id}"
  end
end
