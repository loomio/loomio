# frozen_string_literal: true

class Views::NotificationMailer::Common::Notification < Views::ApplicationMailer::Component

  def initialize(topic_item:, recipient:, event_key:, poll: nil, url: nil, message: nil, title: nil, translation_values: {}, with_title: false, content: nil)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @poll = poll
    @explicit_url = url
    @explicit_message = message
    @title = title
    @translation_values = translation_values
    @with_title = with_title
    @content = content
  end

  def view_template
    div(class: "email-notification") do
      table(class: "email-layout-table", width: "100%") do
        render_notification_row
      end
    end
  end

  private

  def render_notification_row
    tr do
      if @topic_item.user
        td(valign: "top", width: 36, style: "width: 36px") do
          render Views::NotificationMailer::Common::Avatar.new(user: @topic_item.user)
        end
      end
      td(valign: "top") do
        strong(class: "email-notification-text") do
          raw t(notification_key, **notification_params).html_safe
        end
        render_message if message.present?
        render_content if @content
      end
    end
  end

  def render_message
    div(class: "email-notification-content") do
      i { raw MarkdownService.render_plain_text(message) }
    end
  end

  def render_content
    div(class: "email-notification-content") { render @content }
  end

  def notification_key
    title_mode = @with_title ? "with_title" : "without_title"
    author_suffix = author_variant? ? "_author" : ""
    "notifications.#{title_mode}.#{@event_key}#{author_suffix}"
  end

  def author_variant?
    @topic_item.itemable.respond_to?(:author_id) &&
      @recipient.id == @topic_item.itemable.author_id &&
      I18n.exists?("notifications.#{@with_title ? 'with_title' : 'without_title'}.#{@event_key}_author")
  end

  def notification_params
    translated_values = @translation_values.symbolize_keys
    translated_name = translated_values.delete(:name)
    translated_values[:actor] = translated_name if translated_name.present?

    {
      actor: @topic_item.user.name_or_username,
      title: title_link_html,
      poll_type: @poll ? t("poll_types.#{@poll.poll_type}") : nil,
      site_name: AppConfig.theme[:site_name]
    }.merge(translated_values).merge(title: title_link_html)
  end

  def url
    @explicit_url || tracked_url(@topic_item.itemable, recipient: @recipient)
  end

  def message
    return @explicit_message unless @explicit_message.nil?
    return unless @topic_item.is_a?(NotificationRenderingContext)

    @topic_item.recipient_message
  end

  def title_link_html
    return @title if @title
    title_text = TranslationService.plain_text(@topic_item.itemable.title_model, :title, @recipient)
    capture { a(href: url) { title_text } }
  end
end
