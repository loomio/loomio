class Events::PollGoalReached < Event
  include Events::PollEvent

  def self.publish!(poll)
    create(kind: "poll_goal_reached",
           eventable: poll).tap { |e| EventBus.broadcast('poll_goal_reached_event', e) }
  end

  private

  def email_recipients
    User.where(id: eventable.author_id)
  end

  def notification_recipients
    User.none # TODO: add a goal_reached notification?
  end
end
