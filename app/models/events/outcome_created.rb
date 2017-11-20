class Events::OutcomeCreated < Event
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::Notify::Mentions
  include Events::LiveUpdate

  def self.publish!(outcome)
    super outcome,
          user: outcome.author,
          discussion: outcome.poll.discussion
  end

  private

  def notify_author?
    poll.author_receives_outcome
  end
end
