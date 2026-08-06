# frozen_string_literal: true

class Views::Admin::Api < Views::Admin::Layout
  def initialize(markdown:, status:)
    super(title: "API")
    @markdown = markdown
    @status = status
  end

  def view_template
    page_header("B3 API")
    render_status
    article(class: "admin-panel admin-markdown") do
      raw MarkdownService.render_html(@markdown).html_safe
    end
  end

  private

  def render_status
    panel("Status") do
      case @status
      when :enabled
        p(class: "admin-api-status admin-api-status--enabled") { "Enabled" }
        p { "B3_API_KEY is set. Its value is not displayed here" }
      when :disabled_invalid
        p(class: "admin-api-status admin-api-status--disabled") { "Disabled" }
        p { "B3_API_KEY is set, but it must be longer than 16 characters" }
      else
        p(class: "admin-api-status admin-api-status--disabled") { "Disabled" }
        p { "B3_API_KEY is not set" }
      end
      p do
        plain "To enable the API, set "
        code { "B3_API_KEY" }
        plain " to a secret longer than 16 characters in the Rails web process environment, then restart it. For the included Docker deployment, set it in "
        code { "deploy/env" }
        plain ". Do not store the key in the repository"
      end
    end
  end
end
