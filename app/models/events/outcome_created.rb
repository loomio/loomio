class Events::OutcomeCreated < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::Visitors

  def self.publish!(outcome)
    create(kind: "outcome_created",
           user: outcome.author,
           eventable: outcome,
           announcement: outcome.make_announcement,
           discussion: outcome.poll.discussion,
           created_at: outcome.created_at).tap { |e| EventBus.broadcast('outcome_created_event', e) }
  end

  private

  def notify_author?
    poll.author_receives_outcome
  end

  def email_visitors
    if announcement
      poll.visitors
    else
      Visitor.none
    end
  end
end
