class Events::PollEdited < Event
  include Events::PollEvent

  def self.publish!(version, actor, announcement = false)
    create(kind: "poll_edited",
           user: actor,
           eventable: version,
           parent: version.created_event,
           announcement: announcement,
           discussion: version.item.discussion,
           created_at: version.created_at).tap { |e| EventBus.broadcast('poll_edited_event', e) }
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
