# frozen_string_literal: true

class Views::Chatbot::Markdown::Stance < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(topic_item:, poll: nil, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    return unless @topic_item.itemable.shared_update_visible?

    render_notification_text(@topic_item, @poll)
    md "\n"
    render_title(@topic_item.itemable.poll)
    md "\n"

    if @topic_item.itemable.poll.poll_type == "meeting"
      render_meeting_stance_choices(@topic_item.itemable)
    else
      render_stance_choices(@topic_item.itemable)
    end

    md "\n"
    render_body(@topic_item.itemable)
  end
end
