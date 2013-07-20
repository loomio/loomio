#encoding: UTF-8
module ApplicationHelper
  def time_formatted_relative_to_age(time)
    current_time = Time.now
    if time.to_date == Time.now.to_date
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

    classes = "btn btn-app" + extra_classes
    content_tag(:a, href: href, 'data-method' => method, class: classes, id: id,
                'data-toggle' => data_toggle, 'data-confirm' => data_confirm, title: title) do
      image_tag(icon, class: 'button-icon') + content_tag(:span, text)
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
        :link_attributes     => {target: '_blank'}
        )
      markdown = Redcarpet::Markdown.new(renderer, *options)
      output = markdown.render(text)
    else
      output = Rinku.auto_link(simple_format(html_escape(text)), mode=:all, 'target="_blank"')
    end

    Redcarpet::Render::SmartyPants.render(output).html_safe
  end

  def show_contribution_icon?
    current_user && !current_user.belongs_to_paying_group?
  end

  def visitor?
    !user_signed_in?
  end

  def email_belongs_to_existing_user?(email)
    User.find_by_email(email).present?
  end
end
