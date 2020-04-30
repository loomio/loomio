module Events::Notify::Mentions
  def trigger!
    super
    self.notify_mentions!
  end

  # send event notifications
  def notify_mentions!
    return unless eventable.newly_mentioned_users.any?
    if eventable.respond_to?(:discussion)
      eventable.newly_mentioned_users.each do |guest|
        if !eventable.group.members.exists?(guest.id)
          eventable.discussion.add_guest!(guest, user)
        end
      end
    end
    Events::UserMentioned.publish! eventable, user, eventable.newly_mentioned_users
  end

  private

  # remove newly_mentioned_users from those emailed by following
  def email_recipients
    super.where.not(id: eventable.newly_mentioned_users)
  end
end
