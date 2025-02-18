module Events::Notify::Mentions
  def trigger!
    super
    notify_mentioned_groups!
    notify_mentioned_users!
  end

  # send event notifications
  def notify_mentioned_users!
    return if eventable.newly_mentioned_users.empty?

    Events::UserMentioned.publish! eventable, user, eventable.newly_mentioned_users.pluck(:id)
  end

  def notify_mentioned_groups!
    return if eventable.newly_mentioned_groups.empty?

    Events::GroupMentioned.publish! eventable, user, eventable.newly_mentioned_groups.pluck(:id)
  end

  private

  # remove newly_mentioned_users from those emailed by following
  def email_recipients
    super.where.not(id: eventable.newly_mentioned_users)
  end
end
