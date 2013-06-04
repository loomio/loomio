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

  def render_rich_text(text, md_boolean=true)
    if text == nil #there's gotta be a better way to do this? text=" " in args wasn't working
      text = " "
    end

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

  def help_text_args
    args = {}
    case "#{controller_name} #{action_name}"
      when 'discussions show'
        args = { header: t("discussion_helper_text.header"), message: t("discussion_helper_text.message").html_safe, path: dismiss_discussion_notice_for_user_path }
      when 'groups show'
        args = { header: t("group_helper_text.header"), message: t("group_helper_text.message").html_safe, path: dismiss_group_notice_for_user_path }
      when 'dashboard show'
        args = { header: t("dashboard_helper_text.header"), message: t("dashboard_helper_text.message").html_safe, path: dismiss_dashboard_notice_for_user_path }
    end
    args
  end

  def render_help_text
    unless help_text_dismissed?
      render '/application/help_text', args: help_text_args
    end
  end
end

