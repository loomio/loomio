class NotificationItems::NewVote < NotificationItem
  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    position = Vote::POSITION_VERBS[@notification.eventable.position]
    I18n.t('notifications.new_vote', position: position)
  end

  def title
    @notification.eventable.motion.name
  end

  def group_full_name
    @notification.eventable.group_full_name
  end

  def link
    discussion_path = url_helpers.discussion_path(@notification.eventable.discussion)
    discussion_path + "?proposal=#{@notification.eventable.motion.id}"
  end
end