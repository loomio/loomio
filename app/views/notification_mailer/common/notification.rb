# frozen_string_literal: true

class Views::NotificationMailer::Common::Notification < Views::ApplicationMailer::Component

  def initialize(topic_item:, recipient:, event_key:, poll: nil, url: nil, message: nil, title: nil, with_title: false)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @poll = poll
    @explicit_url = url
    @explicit_message = message
    @title = title
    @with_title = with_title
  end

  def view_template
    div(class: "mb-2 py-1") do
      table(class: "v-layout-table") do
        render_header_row
        render_message_row if message.present?
      end
    end
  end

  private

  def render_header_row
    tr do
      if @topic_item.user
        td do
          render Views::NotificationMailer::Common::Avatar.new(user: @topic_item.user)
        end
      end
      td(class: "base-mailer__event-headline", style: "width: 100%") do
        h2(class: "text-subtitle-1 ml-2") do
          raw t(notification_key, **notification_params).html_safe
        end
      end
    end
  end

  def render_message_row
    tr do
      td(colspan: "2") do
        p do
          i { raw MarkdownService.render_plain_text(message) }
        end
      end
    end
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
    {
      actor: @topic_item.user.name_or_username,
      title: title_link_html,
      poll_type: @poll ? t("poll_types.#{@poll.poll_type}") : nil,
      site_name: AppConfig.theme[:site_name]
    }
  end

  def url
    @explicit_url || tracked_url(@topic_item.itemable, recipient: @recipient)
  end

  def message
    @explicit_message.nil? ? @topic_item.recipient_message : @explicit_message
  end

  def title_link_html
    return @title if @title
    title_text = TranslationService.plain_text(@topic_item.itemable.title_model, :title, @recipient)
    capture { a(href: url) { title_text } }
  end
end
