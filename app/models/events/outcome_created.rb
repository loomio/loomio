class Events::OutcomeCreated < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::LiveUpdate

  def self.publish!(outcome)
    super outcome,
          user: outcome.author,
          announcement: outcome.make_announcement,
          discussion: outcome.poll.discussion
  end

  private

  def notify_author?
    poll.author_receives_outcome
  end
end
