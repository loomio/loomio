class NotificationItems::NewVote < NotificationItem
  def initialize(notification)
    @notification = notification
  end

  def action_text
    position = I18n.t(@notification.eventable.position, scope: [:position_verbs, :past_tense])
    I18n.t('notifications.new_vote', position: position)
  end

  def title
    @notification.eventable.motion.name
  end

  def group_full_name
    @notification.eventable.group_full_name
  end

  def link
    discussion_path = Routing.discussion_path(@notification.eventable.discussion)
    discussion_path + "?proposal=#{@notification.eventable.motion.key}"
  end
end
