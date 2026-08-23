# frozen_string_literal: true

class Views::Chatbot::Markdown::Poll < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(topic_item:, poll:, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render_notification_text(@topic_item, @poll)
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
