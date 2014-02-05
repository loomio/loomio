module DiscussionsHelper
  include Twitter::Extractor
  include Twitter::Autolink

  def enough_activity_for_jump_link?
    @discussion.items_count > 3
  end

  def discussion_activity_count_for(discussion, user)
    discussion.as_read_by(user).unread_comments_count
  end

  def path_of_latest_activity
    if current_page == @reader.first_unread_page
      '#latest-activity'.html_safe
    else
      discussion_path(@discussion, page: @reader.first_unread_page, anchor: 'latest-activity')
    end
  end

  def path_of_add_comment
    if current_page == @reader.first_unread_page
      '#comment-input'
    else
      if actual_total_pages == 1
        discussion_path(@discussion, anchor: 'comment-input')
      else
        discussion_path(@discussion, page: actual_total_pages, anchor: 'comment-input')
      end
    end
  end

  def enabled_icon_class_for(discussion, user)
    if discussion.as_read_by(user).unread_content_exists?
      "enabled-icon"
    else
      "disabled-icon"
    end
  end

  def css_class_unread_discussion_activity_for(page_group, discussion, user)
    css_class = "discussion-preview"
    css_class += " showing-group" if (not discussion.group.parent_id.nil?) && (page_group && (page_group.parent_id.nil?))
    css_class += " unread" if discussion.as_read_by(user).unread_content_exists?
    css_class
  end

  def css_class_for_closing_at(motion)
    css_class = "popover-close-date label"

    if motion.voting?
      hours_left = (((Time.now - motion.closing_at) / 60) / 60) * -1
      css_class += " color-urgent" if hours_left < 30
      css_class += " color-warning" if (hours_left >= 3) && (hours_left <= 24)
      css_class += " color-ok" if hours_left > 24
    end
    css_class
  end

  def add_mention_links(comment)
    auto_link_usernames_or_lists(comment, :username_url_base => "#", :username_include_symbol => true)
  end

  def css_for_markdown_link(target, setting)
    return "icon-ok" if (target.uses_markdown == setting)
  end

  def markdown_img(uses_markdown)
    if uses_markdown
      image_tag("markdown_on.png", class: 'markdown-icon markdown-on')
    else
      image_tag("markdown_off.png", class: 'markdown-icon markdown-off')
    end
  end

  def last_page?
    actual_total_pages == current_page
  end

  def actual_total_pages
    if @activity.total_pages == 0
      1
    else
      @activity.total_pages
    end
  end

  def current_page
    @current_page ||= requested_or_first_unread_page
  end

  def requested_or_first_unread_page
    if params[:page]
      params[:page].to_i
    else
      @reader.first_unread_page
    end
  end

  def user_has_not_read_event?(event)
    if @reader and @reader.last_read_at.present?
      if event.belongs_to?(current_user)
        false
      else
        @reader.last_read_at < event.updated_at
      end
    else
      false
    end
  end

  def discussion_privacy_options(discussion)
    options = []
    group =
      if discussion.group_id
        t(:'simple_form.labels.discussion.of') + discussion.group.name
      else
        t :'simple_form.labels.discussion.of_no_group'
      end
    icon =
    header = t "simple_form.labels.discussion.privacy_public_header"
    description = t 'simple_form.labels.discussion.privacy_public_description'
    options << ["<span class='discussion-privacy-setting-header'><i class='icon-globe'></i>#{header}<br /><p>#{description}</p>".html_safe, false]

    header = t "simple_form.labels.discussion.privacy_private_header"
    description = t(:'simple_form.labels.discussion.privacy_private_description', group: group)
    options << ["<span class='discussion-privacy-setting-header'><i class='icon-lock'></i>#{header}<br /><p>#{description}</p>".html_safe, true ]
  end
  
  def current_language
    Translation.language I18n.locale.to_s
  end

  def privacy_language(discussion)
    discussion.private? ? "private" : "public"
  end

  def privacy_icon(discussion)
    discussion.private? ? "lock" : "globe"
  end
end
