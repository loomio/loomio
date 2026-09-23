# frozen_string_literal: true

class Views::Chatbot::Matrix::Discussion < Views::Chatbot::Base
  def initialize(topic_item:, poll: nil, recipient: nil)
    @topic_item = topic_item
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render Views::Chatbot::Matrix::NotificationText.new(topic_item: @topic_item, poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Title.new(itemable: @topic_item.itemable)
    render Views::Chatbot::Matrix::Body.new(itemable: @topic_item.itemable, recipient: @recipient)
    render Views::Chatbot::Matrix::DiscussionUndecided.new(itemable: @topic_item.itemable)
  end
end
