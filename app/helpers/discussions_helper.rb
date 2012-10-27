module DiscussionsHelper
  def discussion_activity_count_for(discussion, user)
    user ? discussion.number_of_comments_since_last_looked(user) : 0
  end

  def enabled_icon_class_for(discussion, user)
    if discussion_activity_count_for(discussion, user) > 0
      "enabled-icon"
    else
      "disabled-icon"
    end
  end

  def css_class_unread_discussion_activity_for(group_page, discussion, user)
    css_class = "discussion-preview"
    css_class += " showing-group" if (group_page && (group_page.not_a_subgroup? && discussion.group.a_subgroup?))
    css_class += " unread" if user_signed_in? && group_page && discussion.unread_by(user)
    css_class
  end

  def css_class_unread_group_activity_for(discussion, user)
    css_class = "group-activity-indicator"
    css_class += " unread-group-activity" if user_signed_in? && params[:group_id] && discussion.has_activity_since_group_last_viewed?(user)
    css_class
  end

  def css_class_for_close_date(motion)
    css_class = "popover-close-date label"

    if motion.close_date
      hours_left = (((Time.now - motion.close_date) / 60) / 60) * -1
      css_class += " color-urgent" if hours_left < 30
      css_class += " color-warning" if (hours_left >= 3) && (hours_left <= 24)
      css_class += " color-ok" if hours_left > 24
    end
    css_class
  end
 
  def render_position_message(vote)
    message = vote.position_to_s
    if vote.previous_vote
      message += " (previously " + vote.previous_vote.position_to_s + ")"
    end
    message += vote.statement.blank? ? "." : ":"
    message
  end
end
