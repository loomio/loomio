# frozen_string_literal: true

class Views::Chatbot::Markdown::Base < Views::Chatbot::Base
  private

  def md(text)
    raw safe(text.to_s)
  end
end
