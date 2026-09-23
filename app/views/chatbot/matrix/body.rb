# frozen_string_literal: true

class Views::Chatbot::Matrix::Body < Views::Chatbot::Base
  def initialize(itemable:, recipient: nil)
    @itemable = itemable
    @recipient = recipient
  end

  def view_template
    raw TranslationService.formatted_text(@itemable, :body, @recipient)
    render Views::Chatbot::Matrix::Attachments.new(resource: @itemable)
  end
end
