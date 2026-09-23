# frozen_string_literal: true

class Views::Chatbot::Slack::Comment < Views::Chatbot::Slack::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(topic_item:, poll: nil, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    slack_convert { render_notification_text(@topic_item, @poll) }
    md "\n"
    slack_convert { render_title(@topic_item.itemable.topic.topicable) }
    md "\n"
    slack_convert { render_body(@topic_item.itemable) }
    md "\n"
  end
end
