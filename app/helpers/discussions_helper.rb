module DiscussionsHelper
  def activity_count_for(discussion, user)
    user ? user.discussion_activity_count(discussion) : 0
  end

  def enabled_icon_class_for(discussion, user)
    if activity_count_for(discussion, user) > 0
      "enabled-icon"
    else
      "disabled-icon"
    end
  end

  def css_class_for(discussion, user)
    css_class = "discussion-preview "

    motion = discussion.current_motion
    if motion.present? && motion.voting? && motion.blocked?
      suffix = "blocked"
    else
      suffix = ""
      if discussion.has_activity_unread_by?(user)
        suffix = "unread"
      end
    end

    css_class + suffix
  end
end
