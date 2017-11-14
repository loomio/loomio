class Events::PollEdited < Event
  include Events::PollEvent

  def self.publish!(version, actor, announcement = false)
    super version,
          user: actor,
          discussion: version.item.discussion,
          announcement: announcement
  end

  def poll
    eventable.item
  end

  private

  # notify those who have already participated in the poll of the change
  def announcement_notification_recipients
    poll.participants
  end
  alias :announcement_email_recipients :announcement_notification_recipients

  def specified_notification_recipients
    Queries::UsersToMentionQuery.for(poll)
  end
  alias :specified_email_recipients :specified_notification_recipients
end
