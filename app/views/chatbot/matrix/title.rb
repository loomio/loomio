# frozen_string_literal: true

class Views::Chatbot::Matrix::Title < Views::Chatbot::Base
  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    h3 { link_to @eventable.title, polymorphic_url(@eventable) }
  end
end
