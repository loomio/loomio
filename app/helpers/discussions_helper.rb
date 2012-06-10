module DiscussionsHelper
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

  def css_class_for(discussion)
    css_class = "discussion panel "

    motion = discussion.current_motion
    if motion.present? && motion.voting? && motion.blocked?
      suffix = "blocked"
    else
      suffix = "unread"
      if (current_user && (current_user.discussion_activity_count(discussion) == 0))
        suffix = "read"
      end
    end

    css_class + suffix
  end

  def link_to_discussion(discussion)
    title = truncate(discussion.title, :length => 75, :separator => ' ')
    link = link_to title, discussion_path(discussion), class: "discussion-link"
    group = discussion.group
    if group.parent
      group_link = link_to(group.name, group_path(group), class: "group-link")
      group_link += content_tag :i, '', class: 'icon-play-tiny'
      link = group_link + link
    end
    link
  end

  def fancy_discussion_name(discussion)
    title = truncate(discussion.title, :length => 75, :separator => ' ')
    text = sanitize(title)
    group = discussion.group
    if group.parent
      group_text = sanitize("#{group.name} ")
      group_text += content_tag :span, "\u25B6", class: 'name-separator'
      text = "#{group_text} #{text}".html_safe
    end
    text
  end
end
