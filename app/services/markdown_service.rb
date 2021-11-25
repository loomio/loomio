module MarkdownService
  MARKDOWN_OPTIONS = [
    no_intra_emphasis:    true,
    tables:               true,
    fenced_code_blocks:   true,
    autolink:             true,
    strikethrough:        true,
    space_after_headers:  true,
    superscript:          true,
    underline:            true
  ].freeze

  def self.render_html(text)
    return '' if text.nil?
    renderer = LoomioMarkdown.new(filter_html: true, hard_wrap: true, link_attributes: {rel: "nofollow ugc noreferrer noopener", target: :_blank})
    Redcarpet::Markdown.new(renderer, *MARKDOWN_OPTIONS).render(text)
  end
end
