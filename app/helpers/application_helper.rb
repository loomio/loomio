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
    result += "Loomio"
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


