class Events::PollGoalReached < Event
  include Events::EmailUser

  def self.publish!(poll)
    create(kind: "poll_goal_reached",
           eventable: poll).tap { |e| EventBus.broadcast('poll_goal_reached_event', e) }
  end

  private

  def communities
    @communities ||= eventable.communities
  end

  def email_recipients
    User.where(id: eventable.author_id)
  end
end
