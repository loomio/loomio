class DiscussionItems::MotionClosed < DiscussionItem
  attr_reader :event, :motion

  def initialize(event, motion)
    @event, @motion = event, motion
  end

  def icon
    'proposal-icon'
  end

  def actor
    return "" if event.user.nil?
    event.user
  end

  def header
    I18n.t('discussion_items.motion_closed.by_expiry') + ": "
  end

  def group
    motion.group
  end

  def body
    " #{motion.name}"
  end

  def time
    event.created_at
  end
end
