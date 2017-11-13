class Events::OutcomeCreated < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::LiveUpdate

  def self.publish!(outcome)
    super outcome,
          user: outcome.author,
          discussion: outcome.poll.discussion,
          announcement: outcome.make_announcement
  end

  private

  def notify_author?
    poll.author_receives_outcome
  end
end
