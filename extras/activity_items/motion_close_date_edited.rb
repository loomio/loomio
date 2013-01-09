class ActivityItems::MotionCloseDateEdited
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
    event.user
  end

  def header
    'changed the closing date for the proposal'
  end

  def body
    ""
  end

  def time
    event.created_at
  end
end