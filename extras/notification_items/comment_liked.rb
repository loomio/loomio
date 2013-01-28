class NotificationItems::CommentLiked < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.comment_liked')
  end

  def link
    discussion_path = url_helpers.discussion_path(@notification.eventable)
    discussion_path + "#comment-#{@notification.eventable.comment_id}"
  end
end