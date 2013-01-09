class NotificationItems::NewDiscussion < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

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

  def link
    url_helpers.discussion_path(@notification.eventable)
  end
end