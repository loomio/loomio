class NotificationItems::NewMotion < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

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
    url_helpers.discussion_path(@notification.eventable.discussion)
  end
end