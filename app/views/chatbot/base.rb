# frozen_string_literal: true

class Views::Chatbot::Base < Views::Application::Component
  private

  def markdown_escape(text)
    MarkdownService.escape_inline(text)
  end

  def html_escape_values(values)
    values.transform_values { |value| ERB::Util.html_escape(value) }
  end
end
