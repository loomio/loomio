class MotionClosedActivityItem
  attr_reader :group, :actor, :header, :body, :time

  def initialize(event, motion)
    @group, @actor, @header, @body, @time = motion.group, activity_actor(event.user),
      activity_header(event.user), " \"#{motion.name}\"", event.created_at
  end

  def icon
    'proposal-icon'
  end

  def position
    nil
  end

  def activity_actor(closer)
    closer.nil? ? "" : closer
  end

  def activity_header(closer)
    closer.nil? ? "Proposal closed:" : "closed the proposal:"
  end
end