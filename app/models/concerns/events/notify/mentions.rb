module Events::Notify::Mentions
  def trigger!
    super
    self.notify_mentions!
  end

  # send event notifications
  def notify_mentions!
    mention_recipients.each { |mentionee| Events::UserMentioned.publish!(eventable, user, mentionee) }
  end
  handle_asynchronously :notify_mentions!

  private

  def mention_recipients
    eventable.mentioned_group_members
             .without(eventable.group.members.mentioned_in(eventable)) # avoid re-mentioning users when editing
             .without(eventable.users_to_not_mention)
             .without(user)
  end
end
