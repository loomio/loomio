# frozen_string_literal: true

class Views::Chatbot::Matrix::Body < Views::Chatbot::Base
  def initialize(eventable:, recipient: nil)
    @eventable = eventable
    @recipient = recipient
  end

  def view_template
    raw TranslationService.formatted_text(@eventable, :body, @recipient)
    render Views::Chatbot::Matrix::Attachments.new(resource: @eventable)
  end
end
