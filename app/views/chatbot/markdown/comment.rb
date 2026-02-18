# frozen_string_literal: true

class Views::Chatbot::Markdown::Comment < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(event:, poll: nil, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render_notification_text(@event, @poll)
    md "\n"
    render_title(@event.eventable.discussion)
    md "\n"
    render_body(@event.eventable)
  end
end
