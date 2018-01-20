class Events::PollReopened < Event
  def self.publish!(poll, actor)
    super poll, user: actor, parent: poll.created_event
  end
end
