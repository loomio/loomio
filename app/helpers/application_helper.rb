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

    renderer = MarkdownRenderer.new(
      :filter_html => true,
      :hard_wrap => true
    )
    
    markdown = Redcarpet::Markdown.new(renderer, *options)
    markdown.render(text).html_safe
  end

  def info_message_read?(user)
    case controller_name
      when 'discussions'
        return (not user.has_read_discussion_notice?)
      when 'groups'
        return (not user.has_read_group_notice?) && @group.parent.nil?
      when 'dashboard'
        return (not user.has_read_dashboard_notice?)
    end
  end

  def helper_info_path
    case controller_name
      when 'discussions'
        return dismiss_discussion_notice_for_user_path
      when 'groups'
        return dismiss_group_notice_for_user_path
      when 'dashboard'
        return dismiss_dashboard_notice_for_user_path
    end
  end

  def helper_info_message(user)
    case controller_name
      when 'discussions'
        message = "The discussion topic is at the top of the page, followed by background information and context.\n\n"
        message += "Discussion is on the left: to add a comment, write in the text box and click‘Post comment’.\n\n"
        message += "Decisions are on the right. If you think the group is ready to make a decision, "
        message += "you can make a proposal for the group to consider. If someone has already made a proposal, "
        message += "you can see how the group feels on the pie graph, and state your position underneath.\n\n"
      when 'groups'
        message = "This is the Group page for \"#{@group.full_name}\". \n\n Here you can see this group’s discussions, "
        message += "a description of what the group is for, "
        message += "You can start a discussion on a new topic by clicking on the ‘Start a discussion’ button.\n\n"
      when 'dashboard'
        message = "Welcome to Loomio!\n This is the Home page, where you can see a list of the discussions "
        message += "going on in all of your groups. To the right is a list of the groups you are a member of. "
        message += "You can start a discussion on a new topic by clicking on the “Start a discussion” button.\n\n"
        message += "If you have any questions or feedback we’d love to hear from you: "
        message += "#{link_to "contact@loomio.org", 'mailto:contact@loomio.org', :target =>'_blank'}\n\n"
    end
  end
end


