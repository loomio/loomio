# frozen_string_literal: true

class Views::Chatbot::Matrix::Poll < Views::Chatbot::Base
  def initialize(event:, poll:, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    render Views::Chatbot::Matrix::NotificationText.new(event: @event, poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Title.new(eventable: @poll)
    render Views::Chatbot::Matrix::Outcome.new(poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Body.new(eventable: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::VotingPeriod.new(poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Vote.new(poll: @poll, recipient: @recipient)
    render Views::Chatbot::Matrix::Rules.new(poll: @poll)
    render Views::Chatbot::Matrix::Results.new(poll: @poll, recipient: @recipient)
  end
end
