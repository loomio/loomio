module DiscussionsHelper
  include Twitter::Extractor
  include Twitter::Autolink
  def discussion_activity_count_for(discussion, user)
    discussion.number_of_comments_since_last_looked(user)
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
    css_class += " unread" if discussion.number_of_comments_since_last_looked(user) > 0 || discussion.never_read_by(user)
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

  def add_mention_links(comment)
    auto_link_usernames_or_lists(comment, :username_url_base => "#", :username_include_symbol => true)
  end

  def css_for_markdown_link(current_user, setting)
    return "icon-ok" if (current_user.uses_markdown == setting)
  end

  def markdown_img(uses_markdown)
    if uses_markdown
      image_tag("markdown_on.png", class: 'markdown-icon markdown-on')
    else
      image_tag("markdown_off.png", class: 'markdown-icon markdown-off')
    end
  end
end
