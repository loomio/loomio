# frozen_string_literal: true

class Views::Chatbot::Matrix::Comment < Views::Chatbot::Base
  def initialize(event:, poll: nil, recipient: nil)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render Views::Chatbot::Matrix::NotificationText.new(event: @event, poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Body.new(eventable: @event.eventable, recipient: @recipient)
  end
end
