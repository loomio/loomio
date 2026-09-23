# frozen_string_literal: true

class Views::Chatbot::Markdown::Comment < Views::Chatbot::Markdown::Base
  include Views::Chatbot::Markdown::Concerns

  def initialize(topic_item:, poll: nil, recipient:)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render_notification_text(@topic_item, @poll)
    md "\n"
    render_title(@topic_item.itemable.topic.topicable)
    md "\n"
    render_body(@topic_item.itemable)
  end
end
