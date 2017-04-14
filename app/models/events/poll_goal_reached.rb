class Events::PollGoalReached < Event
  def self.publish!(poll)
    create(kind: "poll_goal_reached",
           eventable: poll).tap { |e| EventBus.broadcast('poll_goal_reached_event', e) }
  end
end
