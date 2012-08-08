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
    motion = discussion.current_motion
    css_class = ["discussion-preview"]
    css_class << "blocked" if motion.present? && motion.voting? && motion.blocked?
    css_class << "unread" if discussion.has_activity_unread_by?(user) || signed_out?
    css_class.join(" ")
  end
end
