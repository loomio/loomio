module DiscussionsHelper

  def latest_history_time_for(discussion)
    last_updated = discussion.latest_history_time
    date_format = last_updated.to_date == Date.today ? "%I:%M %p" : "%d %b"
    last_updated.strftime(date_format)
  end

  def activity_count_for(discussion, user)
    user ? user.discussion_activity_count(discussion) : 0
  end

  def enabled_icon_class_for(discussion, user)
    if activity_count_for(discussion, user) > 0
      "discussion-enabled-icon"
    else
      "discussion-disabled-icon"
    end
  end

  def css_class_for(motion)
    css_class = "discussion panel "

    if motion.present? && motion.voting? && motion.blocked?
      suffix = "blocked"
    else
      suffix = "voting"
    end

    css_class + suffix
  end
end
