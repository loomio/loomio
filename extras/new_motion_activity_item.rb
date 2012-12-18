class NewMotionActivityItem
  attr_reader :group, :actor, :body, :time

  def initialize(motion)
    @group, @actor, @body, @time = motion.group, motion.author, " \"#{motion.name}\"", motion.created_at
  end

  def icon
    'proposal-icon'
  end

  def position
    nil
  end

  def header
    'created a proposal:'
  end
end