class NotificationItems::CommentRepliedTo < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.comment_replied_to')
  end

  def linkable
    [@notification.eventable.discussion, {anchor: "comment-#{@notification.eventable.id}"}]
  end
end
