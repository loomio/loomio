# frozen_string_literal: true

class Views::Chatbot::Markdown::Stance < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(event:, poll: nil, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render_notification_text(@event, @poll)
    md "\n"
    render_title(@event.eventable.poll)
    md "\n"

    if @event.eventable.poll.poll_type == "meeting"
      render_meeting_stance_choices(@event.eventable)
    else
      render_stance_choices(@event.eventable)
    end

    md "\n"
    render_body(@event.eventable)
  end
end
