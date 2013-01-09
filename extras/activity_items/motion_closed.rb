class ActivityItems::MotionClosed
  attr_reader :event, :motion

  def initialize(event, motion)
    @event, @motion = event, motion
  end

  def icon
    'proposal-icon'
  end

  def group
    motion.group
  end

  def actor
    event.user.nil? ? "" : event.user
  end

  def header
    event.user.nil? ? "Proposal closed:" : "closed the proposal:"
  end

  def body
    " \"#{motion.name}\""
  end

  def time
    event.created_at
  end
end