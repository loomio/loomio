# frozen_string_literal: true

class Views::Chatbot::Slack::Notification < Views::Chatbot::Slack::Base
  def initialize(event:, poll: nil, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    url = polymorphic_url(@event.eventable)
    message = @event.recipient_message
    poll_type = @poll ? t("poll_types.#{@poll.poll_type}") : nil

    sd t("notifications.with_title.#{@event.kind}",
         actor: @event.user.name,
         title: "[#{@event.eventable.title}](#{url})",
         poll_type: poll_type,
         site_name: AppConfig.theme[:site_name])
    md "\n"

    if message.present?
      md "  #{force_plain_text(message)}\n"
    end
  end
end
