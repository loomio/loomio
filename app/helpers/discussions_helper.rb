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

  def css_class_unread_discussion_activity_for(page_group, discussion, user)
    css_class = "discussion-preview"
    css_class += " showing-group" if (not discussion.group.parent.nil?) && (page_group && (page_group.parent.nil?))
    css_class += " unread" if user_signed_in? && discussion.unread_by(user)
    css_class
  end

  def css_class_unread_group_activity_for(discussion, user)
    css_class = "group-activity-indicator"
    css_class += " unread-group-activity" if user_signed_in? && params[:group_id] && discussion.has_activity_since_group_last_viewed?(user)
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
