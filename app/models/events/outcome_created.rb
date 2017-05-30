class Events::OutcomeCreated < Event
  include Events::PollEvent

  def self.publish!(outcome)
    create(kind: "outcome_created",
           user: outcome.author,
           eventable: outcome,
           announcement: outcome.make_announcement,
           discussion: outcome.poll.discussion,
           created_at: outcome.created_at).tap { |e| EventBus.broadcast('outcome_created_event', e) }
  end

  def attachments
    return unless ics = eventable.calendar_invite
    {"event.ics": { mime_type: 'text/calendar', content: ics } }
  end
end
