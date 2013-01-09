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
    return I18n.t('discussion_items.motion_closed.by_expirey') + ": "if event.user.nil?
    I18n.t('discussion_items.motion_closed.by_user') + ": "
  end

  def group
    motion.group
  end

  def body
    " \"#{motion.name}\""
  end

  def time
    event.created_at
  end
end