module DiscussionsHelper
 
  def last_update_date_for(discussion)
    if discussion.comments.size > 0
      last_updated = discussion.last_comment_updated_at?
    else
      last_updated = discussion.created_at
    end 

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