class DiscussionItems::MotionClosedByUser < DiscussionItems::MotionClosed
  def header
    return I18n.t('discussion_items.motion_closed.by_user') + ": "
  end
end