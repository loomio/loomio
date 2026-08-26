# frozen_string_literal: true

class Views::Chatbot::Slack::Stance < Views::Chatbot::Slack::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(topic_item:, poll: nil, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    return unless @topic_item.itemable.shared_update_visible?

    slack_convert { render_notification_text(@topic_item, @poll) }
    md "\n"
    slack_convert { render_title(@topic_item.itemable.poll) }
    md "\n"

    if @topic_item.itemable.poll.poll_type == "meeting"
      render_meeting_stance_choices(@topic_item.itemable)
    else
      render_stance_choices(@topic_item.itemable)
    end

    slack_convert { render_body(@topic_item.itemable) }
  end
end
