class NotificationItems::NewVote < NotificationItem
  # note this is not created any more.. 
  # someone should sweep the db and delete the files
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

  def linkable
    [@notification.eventable.discussion,
     {proposal:@notification.eventable.motion.key}]
  end
end
