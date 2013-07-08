class DiscussionItems::MotionEdited < DiscussionItem
  attr_reader :event, :motion

  def initialize(event, motion)
    @event, @motion = event, motion
  end

  def icon
    'proposal-icon'
  end

  def actor
    event.user
  end

  def group
    motion.group
  end

  def header
    I18n.t('discussion_items.motion_edited')
  end

  def body
    motion.version_at(event.created_at).edit_message
  end

  def time
    event.created_at
  end
end
