class NotificationItems::NewComment < NotificationItem
  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.new_comment')
  end

  def link
    Routing.discussion_path(@notification.eventable.discussion)
  end
end
