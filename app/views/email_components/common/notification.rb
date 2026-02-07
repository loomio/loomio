# frozen_string_literal: true

class Views::EmailComponents::Common::Notification < Views::Base
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include EmailHelper

  def initialize(event:, recipient:, event_key:, poll: nil, url: nil, message: nil, title: nil, with_title: false)
    @event = event
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
      if @event.user
        td do
          render Views::EmailComponents::Common::Avatar.new(user: @event.user)
        end
      end
      td(class: "base-mailer__event-headline", style: "width: 100%") do
        h2(class: "text-subtitle-1 ml-2") do
          raw t(notification_key, **notification_params).to_s.html_safe
        end
      end
    end
  end

  def render_message_row
    tr do
      td(colspan: "2") do
        p do
          i { raw MarkdownService.render_plain_text(message).html_safe }
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
    @event.eventable.respond_to?(:author_id) &&
      @recipient.id == @event.eventable.author_id &&
      I18n.exists?("notifications.#{@with_title ? 'with_title' : 'without_title'}.#{@event_key}_author")
  end

  def notification_params
    {
      actor: @event.user.name_or_username,
      title: title_link_html,
      poll_type: @poll ? t("poll_types.#{@poll.poll_type}") : nil,
      site_name: AppConfig.theme[:site_name]
    }
  end

  def url
    @explicit_url || tracked_url(@event.eventable)
  end

  def message
    @explicit_message.nil? ? @event.recipient_message : @explicit_message
  end

  def title_link_html
    return @title if @title
    ActionController::Base.helpers.link_to(plain_text(@event.eventable.title_model, :title), url)
  end
end
