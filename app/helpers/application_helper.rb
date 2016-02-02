module ApplicationHelper

  def icon_class_for_volume(volume)
    case volume.to_sym
    when :loud then 'fa-envelope'
    when :normal then 'fa-volume-up'
    when :quiet then 'fa-volume-down'
    when :mute then 'fa-volume-off'
    end
  end

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

  def icon_button(args)
    href = args[:href]
    method = args[:method]
    text = args[:text]
    icon = args[:icon]
    id = args[:id]
    extra_classes = " #{args[:class]}"
    data_toggle = args['data-toggle'] || false
    data_confirm = args['data-confirm'] || false
    title = args[:title] || ""

    classes = "btn btn-default btn-block btn-app" + extra_classes
    content = content_tag(:span, text)
    if icon.present?
      content = image_tag(icon, class: 'button-icon') + content
    end
    content_tag(:a, href: href, 'data-method' => method, class: classes, id: id,
      'data-toggle' => data_toggle, 'data-confirm' => data_confirm, title: title) do
      content
    end
  end

  def signed_out?
    not signed_in?
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

    Redcarpet::Render::SmartyPants.render(output).html_safe
  end

  def visitor?
    !user_signed_in?
  end

  def analytics_scope
    if Rails.env.production? || Rails.env.staging?
      unless controller_name == 'searches'
        yield
      end
    end
  end

  def toggle_unread_path
    options = {}
    unless sifting_unread?
      options[:unread] = true
    end

    if sifting_followed?
      options[:followed] = params[:followed]
    end

    url_for(options)
  end

  def toggle_followed_path
    options = {}
    unless sifting_followed?
      options[:followed] = true
    end

    if sifting_unread?
      options[:unread] = params[:unread]
    end

    url_for(options)
  end

  def sifting_unread?
    current_user && params[:unread]
  end

  def sifting_followed?
    current_user && params[:followed]
  end

  def unread_toggle_class
    'active' if sifting_unread?
  end

  def followed_toggle_class
    'active' if sifting_followed?
  end

  def render_help_container
    ' help-container' if controller_name == 'help'
  end

  def hosted_by_loomio?
    ENV['HOSTED_BY_LOOMIO']
  end

  def third_party_install?
    !hosted_by_loomio?
  end

  def site_hostname
    ENV['CANONICAL_HOST'] || request.host
  end

  def logo_path
    if ENV['APP_LOGO_PATH']
      ENV['APP_LOGO_PATH']
    else
      image_url("navbar-logo-beta.jpg")
    end
  end
end
