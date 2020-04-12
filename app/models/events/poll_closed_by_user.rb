class Events::PollClosedByUser < Event
  include Events::Notify::ThirdParty
  def self.publish!(poll, actor)
    super poll,
          user: actor,
          discussion: poll.discussion,
          created_at: poll.closed_at
  end
end
