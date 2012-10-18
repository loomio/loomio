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

  def set_title(group_name, page_title)
    title = page_title.blank? ? "" : page_title.to_s
    title += " - " unless title.blank? || group_name.blank? 
    title += group_name.to_s unless group_name.blank?
    content_for :title, title 
  end

  def app_icon_button(link, text, icon, id, modal_string)
    # content_tag :div do
    content_tag(:a, :href => link, :class => 'btn btn-grey', :id => id, 'data-toggle' => modal_string) do
      image_tag(:class => "button-icon #{icon}-icon")
      text
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
end


