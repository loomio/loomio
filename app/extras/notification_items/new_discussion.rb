class NotificationItems::NewDiscussion < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def actor
    @notification.eventable.author
  end

  def action_text
    I18n.t('notifications.new_discussion')
  end

  def title
    @notification.eventable.title
  end

  def linkable
    [@notification.eventable]
  end
end
