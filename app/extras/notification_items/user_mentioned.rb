class NotificationItems::UserMentioned < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.user_mentioned')
  end

  def linkable
    [@notification.eventable.discussion,
     {anchor: "comment-#{@notification.eventable.id}"}]
  end
end
