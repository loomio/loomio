class DiscussionItems::NewMotion < DiscussionItem
  attr_reader :motion

  def initialize(motion)
    @motion = motion
  end

  def icon
    'proposal-icon'
  end

  def actor
    motion.author
  end

  def header
    I18n.t('discussion_items.new_motion') + ": "
  end

  def group
    motion.group
  end

  def body
    " #{motion.name}"
  end

  def time
    motion.created_at
  end
end