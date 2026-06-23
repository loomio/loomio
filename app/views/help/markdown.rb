# frozen_string_literal: true

class Views::Help::Markdown < Views::BasicLayout
  def initialize(markdown:, **layout_args)
    super(**layout_args)
    @markdown = markdown
  end

  def view_template
    main(class: "container lmo-markdown-wrapper") do
      raw MarkdownService.render_html(@markdown).html_safe
    end
  end
end
