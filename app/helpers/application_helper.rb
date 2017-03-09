module ApplicationHelper

  def show_login_button?
    controller_name != 'sessions' && !current_user.is_logged_in?
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

  def hosted_by_loomio?
    false
  end

  def login_or_signup_path_for_email(email)
    if email.blank? || !User.find_by(email: email)
      new_user_registration_path
    else
      new_user_session_path
    end
  end

end
