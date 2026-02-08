# frozen_string_literal: true

class Views::ContactMailer::ContactMessage < Views::ApplicationMailer::Base

  def initialize(details:, body:)
    @details = details
    @body = body
  end

  def view_template
    table do
      @details.each_pair do |key, value|
        tr do
          td { plain key }
          if key == :user_id
            td { link_to value, admin_user_url(value) }
          else
            td { plain value }
          end
        end
      end
    end

    hr

    raw MarkdownService.render_html(@body).html_safe
  end
end
