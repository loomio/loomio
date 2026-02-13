# frozen_string_literal: true

class Views::Chatbot::Markdown::Poll < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(event:, poll:, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render_notification_text(@event, @poll)
    md "\n"
    render_title(@poll)
    md "\n"
    render_outcome(@poll)
    render_body(@poll)
    md "\n"
    render_voting_period(@poll)
    render_vote(@poll)
    md "\n"
    render_rules(@poll)
    md "\n"
    render_results(@poll)
  end
end
