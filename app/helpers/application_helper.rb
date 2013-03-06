#encoding: UTF-8
module ApplicationHelper

  def twitterized_type(type)
    case type
      when :alert
        "warning"
      when :error
        "error"
      when :notice
        "info"
      when :success
        "success"
      else
        type.to_s
    end
  end

  def display_title(notifications)
    notification_size = notifications ? notifications.size : 0
    result = ""
    result += "(#{notification_size}) " if notification_size > 0
    result += content_for(:title) + " | " if content_for?(:title)
    result += "Loomio"
    result
  end

  def set_title(group_name, page_title, parent = nil)
    title = page_title.blank? ? "" : page_title.to_s
    title += " - " unless title.blank? || group_name.blank?
    title += parent.name.to_s+" - " unless !parent || parent.name.blank?
    title += group_name.to_s unless group_name.blank?
    content_for :title, title.gsub(/["'<>]/, '')
  end

  def icon_button(link, text, icon, id, is_modal = false)
    modal_string = "modal" if is_modal
    content_tag(:a, :href => link, :class => 'btn btn-grey btn-app', :id => id, 'data-toggle' => modal_string) do
      image_tag(icon, :class => 'button-icon') + text
    end
  end

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end

  def signed_out?
    not signed_in?
  end

  def markdown(text, options=nil)

    if text == nil #there's gotta be a better way to do this? text=" " in args wasn't working
      text = " "
    end
    
    options = [
      :no_intra_emphasis => true,
      :tables => true,
      :fenced_code_blocks => true,
      :autolink => true,
      :strikethrough => true,
      :space_after_headers => true,
      :superscript => true
    ]

    renderer = MarkdownRenderer.new
    
    markdown = Redcarpet::Markdown.new(renderer, *options)
    markdown.render(text).html_safe
  end

  def conditional_markdown(md_boolean, text, options=nil)
    if text == nil #there's gotta be a better way to do this? text=" " in args wasn't working
      text = " "
    end

    if md_boolean
      options = [
        :no_intra_emphasis => true,
        :tables => true,
        :fenced_code_blocks => true,
        :autolink => true,
        :strikethrough => true,
        :space_after_headers => true,
        :superscript => true
      ]

      renderer = MarkdownRenderer.new
      markdown = Redcarpet::Markdown.new(renderer, *options)
      markdown.render(text).html_safe
    else
      simple_format(Rinku.auto_link(text, mode=:all, link_attr=nil, skip_tags=nil))
    end
  end

  def help_text_dismissed?
    return true unless current_user
    case "#{controller_name} #{action_name}"
    when 'discussions show'
      current_user.has_read_discussion_notice?
    when 'groups show'
      current_user.has_read_group_notice?
    when 'dashboard show'
      current_user.has_read_dashboard_notice?
    else
      true
    end
  end

  def dismiss_help_text_path
    case "#{controller_name} #{action_name}"
      when 'discussions show'
        return dismiss_discussion_notice_for_user_path
      when 'groups show'
        return dismiss_group_notice_for_user_path
      when 'dashboard show'
        return dismiss_dashboard_notice_for_user_path
    end
  end

  def help_text(group)
    case "#{controller_name} #{action_name}"
      when 'discussions show'
        t :discussion_help_text
      when 'groups show'
        t :group_help_text, :group_name => group.full_name
      when 'dashboard show'
        t :dashboard_help_text, :link => "#{link_to "contact@loomio.org", 'mailto:contact@loomio.org', :target =>'_blank'}\n\n"
    end
  end

  def render_help_text(group)
    unless help_text_dismissed?
      render '/application/help_text', message: help_text(group), path: dismiss_help_text_path
    end
  end
end


