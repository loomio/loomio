class NotificationItems::NewComment < NotificationItem
  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.new_comment')
  end

  def link
    discussion_path = url_helpers.discussion_path(@notification.eventable.discussion)
  end
end