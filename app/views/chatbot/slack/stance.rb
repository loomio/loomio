# frozen_string_literal: true

class Views::Chatbot::Slack::Stance < Views::Chatbot::Slack::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(event:, poll: nil, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    slack_convert { render_notification_text(@event, @poll) }
    md "\n"
    slack_convert { render_title(@event.eventable.poll) }
    md "\n"

    if @event.eventable.poll.poll_type == "meeting"
      render_meeting_stance_choices(@event.eventable)
    else
      render_stance_choices(@event.eventable)
    end

    slack_convert { render_body(@event.eventable) }
  end
end
