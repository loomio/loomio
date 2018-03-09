class Events::PollClosedByUser < Event
  def self.publish!(poll, actor)
    super poll,
          user: actor,
          parent: poll.created_event,
          discussion: poll.discussion,
          created_at: poll.closed_at
  end
end
