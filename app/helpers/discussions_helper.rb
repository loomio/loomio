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

  def css_class_for(discussion, user)
    motion = discussion.current_motion
    css_class = ["discussion-preview"]
    css_class << "unread" if discussion.number_of_comments_since_last_looked(user) > 0 || signed_out?
    css_class.join(" ")
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
