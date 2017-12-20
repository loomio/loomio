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

  def mentionable
    eventable
  end

  def email_recipients
    super.without(mention_recipients)
  end

  def mention_recipients
    mentionable.mentioned_group_members
               .without(mentionable.group.members.mentioned_in(mentionable)) # avoid re-mentioning users when editing
               .without(mentionable.users_to_not_mention)
               .without(user)
  end
end
