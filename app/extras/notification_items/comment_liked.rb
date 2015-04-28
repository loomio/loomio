class NotificationItems::CommentLiked < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.comment_liked')
  end

  def linkable
    [@notification.eventable.discussion, anchor: "comment-#{@notification.eventable.comment_id}"]
  end
end
