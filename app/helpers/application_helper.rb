module ApplicationHelper

  def time_formatted_relative_to_age(time)
    current_time = Time.zone.now
    if time.to_date == Time.zone.now.to_date
      l(time, format: :for_today)
    elsif time.year != current_time.year
      l(time.to_date, format: :for_another_year)
    else
      l(time.to_date, format: :for_this_year)
    end
  end

  def show_login_button?
    controller_name != 'sessions' && !current_user_or_visitor.is_logged_in?
  end

  def twitterized_type(type)
    case type
      when :alert
        "warning"
      when "alert"
        "warning"
      when :error
        "error"
      when :notice
        "info"
      when "notice"
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

  def render_rich_text(text, md_boolean=true)
    return "" if text.blank?

    if md_boolean
      options = [
        :no_intra_emphasis   => true,
        :tables              => true,
        :fenced_code_blocks  => true,
        :autolink            => true,
        :strikethrough       => true,
        :space_after_headers => true,
        :superscript         => true,
        :underline           => true
      ]

      renderer = Redcarpet::Render::HTML.new(
        :filter_html         => true,
        :hard_wrap           => true,
        :link_attributes     => {target: '_blank'}
        )
      markdown = Redcarpet::Markdown.new(renderer, *options)
      output = markdown.render(text)
    else
      output = Rinku.auto_link(simple_format(html_escape(text)), :all, 'target="_blank"')
    end

    output = Emojifier.emojify!(output)
    Redcarpet::Render::SmartyPants.render(output).html_safe
  end

  def render_help_container
    ' help-container' if controller_name == 'help'
  end

  def hosted_by_loomio?
    false
  end

  def logo_path
    if ENV['APP_LOGO_PATH']
      ENV['APP_LOGO_PATH']
    else
      image_url("navbar-logo-beta.jpg")
    end
  end

  def login_or_signup_path_for_email(email)
    if email.blank? || !User.find_by(email: email)
      new_user_registration_path
    else
      new_user_session_path(email: email)
    end
  end

end
