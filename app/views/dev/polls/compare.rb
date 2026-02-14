# frozen_string_literal: true

class Views::Dev::Polls::Compare < Phlex::HTML
  def initialize(email:, matrix:, markdown:, slack:, print: nil, email_subject: nil)
    @email = email
    @matrix = matrix
    @markdown = markdown
    @slack = slack
    @print = print
    @email_subject = email_subject
  end

  def view_template
    doctype
    html do
      head do
        meta charset: "utf-8"
        title { "Format Comparison" }
        style do
          raw safe(<<~CSS)
            html, body { margin: 0; overflow-x: auto; }
            .compare-subject { padding: 12px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #e8e8e8; font-size: 14px; min-width: fit-content; }
            .compare-subject strong { margin-right: 6px; }
            .compare-grid { display: grid; grid-template-columns: repeat(#{@print ? 5 : 4}, 600px); gap: 12px; padding: 12px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #f5f5f5; width: fit-content; }
            .compare-panel { background: #fff; border: 1px solid #ddd; border-radius: 6px; min-width: 0; overflow: hidden; }
            body.max-width-600 { max-width: none; }
            .compare-header { background: #eee; padding: 8px 12px; font-weight: bold; font-size: 14px; border-bottom: 1px solid #ddd; }
            .compare-body { padding: 12px; }
            .compare-body-text { padding: 12px; white-space: pre-wrap; font-family: "SF Mono", Monaco, Consolas, monospace; font-size: 12px; background: #fafafa; }
          CSS
        end
      end

      body do
        if @email_subject
          div(class: "compare-subject") do
            strong { "Email subject:" }
            plain @email_subject
          end
        end
        div(class: "compare-grid") do
          panel("Print") { render @print } if @print
          panel("Email") { render @email }
          panel("Matrix") { render @matrix }
          panel("Markdown", text: true) { render @markdown }
          panel("Slack", text: true) { render @slack }
        end
      end
    end
  end

  private

  def panel(title, text: false)
    div(class: "compare-panel") do
      div(class: "compare-header") { title }
      div(class: text ? "compare-body-text" : "compare-body") { yield }
    end
  end
end
