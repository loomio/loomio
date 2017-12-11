class Events::OutcomeCreated < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::LiveUpdate

  def self.publish!(outcome)
    create(kind: "outcome_created",
           user: outcome.author,
           eventable: outcome,
           parent: lookup_parent_event(outcome),
           announcement: outcome.make_announcement,
           discussion: outcome.poll.discussion,
           created_at: outcome.created_at).tap { |e| EventBus.broadcast('outcome_created_event', e) }
  end

  private

  def notify_author?
    announcement && poll.author_receives_outcome
  end
end
