# frozen_string_literal: true

class Views::Chatbot::Slack::Comment < Views::Chatbot::Slack::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(event:, poll: nil, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    slack_convert { render_notification_text(@event, @poll) }
    md "\n"
    slack_convert { render_title(@event.eventable.discussion) }
    md "\n"
    slack_convert { render_body(@event.eventable) }
    md "\n"
  end
end
