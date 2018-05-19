module Events::Notify::Mentions
  def trigger!
    super
    self.notify_mentions!
  end

  # send event notifications
  def notify_mentions!
    return unless mention_recipients.any?
    inviter = GroupInviter.new(group: eventable.guest_group,
                               inviter: user,
                               user_ids: mention_recipients.pluck(:id)).invite!
    Events::UserMentioned.publish! eventable, user, mention.mention_recipients
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
    mentionable.mentioned_users
               .where.not(id: mentionable.members.mentioned_in(mentionable)) # avoid re-mentioning users when editing
               .where.not(id: mentionable.users_to_not_mention)
  end
end
