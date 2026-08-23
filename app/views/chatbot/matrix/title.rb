# frozen_string_literal: true

class Views::Chatbot::Matrix::Title < Views::Chatbot::Base
  def initialize(itemable:)
    @itemable = itemable
  end

  def view_template
    h3 { link_to @itemable.title, polymorphic_url(@itemable) }
  end
end
