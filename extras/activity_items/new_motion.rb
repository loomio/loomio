class ActivityItems::NewMotion
  attr_reader :motion

  def initialize(motion)
    @motion = motion
  end

  def icon
    'proposal-icon'
  end

  def group
    motion.group
  end

  def actor
    motion.author
  end

  def header
    'created a proposal:'
  end

  def body
    " \"#{motion.name}\""
  end

  def time
    motion.created_at
  end
end