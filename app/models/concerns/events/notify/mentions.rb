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
    super.where.not(id: mention_recipients)
  end

  def mention_recipients
    mentionable.mentioned_group_members
               .where.not(id: mentionable.group.members.mentioned_in(mentionable)) # avoid re-mentioning users when editing
               .where.not(id: mentionable.users_to_not_mention)
               .where.not(id: user)
  end
end
