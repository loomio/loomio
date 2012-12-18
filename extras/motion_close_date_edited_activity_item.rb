class MotionCloseDateEditedActivityItem
  attr_reader :group, :actor, :time

  def initialize(event, motion)
    @group, @actor, @time = motion.group, event.user, event.created_at
  end

  def icon
    'proposal-icon'
  end

  def position
    nil
  end

  def header
    'changed the closing date for the proposal'
  end

  def body
    ""
  end
end