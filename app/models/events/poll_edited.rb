class Events::PollEdited < Event
  include Events::PollEvent

  def self.publish!(poll, actor, announcement = false)
    version = poll.versions.last
    create(kind: "poll_edited",
           user: actor,
           eventable: poll,
           parent: poll.created_event,
           announcement: announcement,
           discussion: poll.discussion,
           custom_fields: {version_id: version.id, changed_keys: version.object_changes.keys},
           created_at: version.created_at).tap { |e| EventBus.broadcast('poll_edited_event', e) }
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
