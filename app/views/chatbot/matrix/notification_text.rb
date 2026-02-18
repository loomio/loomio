# frozen_string_literal: true

class Views::Chatbot::Matrix::NotificationText < Views::Chatbot::Base
  def initialize(event:, poll: nil, recipient: nil)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    url = polymorphic_url(@event.eventable)
    message = @event.recipient_message
    title = capture { link_to(TranslationService.plain_text(@event.eventable.title_model, :title, @recipient), url) }
    poll_type = @poll ? t("poll_types.#{@poll.poll_type}") : nil

    p { raw t("notifications.without_title.#{@event.kind}", actor: @event.user.name, title: title, poll_type: poll_type, site_name: AppConfig.theme[:site_name]).html_safe }

    if message.present?
      i { raw MarkdownService.render_plain_text(message) }
    end
  end
end
