# frozen_string_literal: true

class Views::Chatbot::Matrix::Comment < Views::Chatbot::Base
  def initialize(topic_item:, poll: nil, recipient: nil)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render Views::Chatbot::Matrix::NotificationText.new(topic_item: @topic_item, poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Body.new(itemable: @topic_item.itemable, recipient: @recipient)
  end
end
