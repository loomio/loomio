class NotificationItems::NewMotion < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.eventable.author
  end

  def action_text
    I18n.t('notifications.new_motion') + ": "
  end

  def title
    @notification.eventable.name
  end

  def group_full_name
    @notification.eventable.group_full_name
  end

  def link
    Routing.discussion_path(@notification.eventable.discussion)
  end
end
