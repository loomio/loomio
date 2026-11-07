# frozen_string_literal: true

# Chatbot and webhook messages have their own base, so changes to the web page
# base (Views::Application::Component) cannot alter message output.
class Views::Chatbot::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include PrettyUrlHelper
  include PollHelper
  include FormattedDateHelper
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::ImagePath
  include Phlex::Rails::Helpers::Sanitize

  def cache_store = Rails.cache

  private

  def markdown_escape(text)
    MarkdownService.escape_inline(text)
  end

  def html_escape_values(values)
    values.transform_values { |value| ERB::Util.html_escape(value) }
  end
end
