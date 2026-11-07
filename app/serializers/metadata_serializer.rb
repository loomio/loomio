class MetadataSerializer < ActiveModel::Serializer
  root false

  private

  # Link previews need a readable excerpt, without section headings or joined paragraphs.
  def description_excerpt(text, format)
    html = format == 'md' ? MarkdownService.render_html(text) : text.to_s
    fragment = Nokogiri::HTML5.fragment(html)
    fragment.css('h1, h2, h3, h4, h5, h6, script, style').remove
    fragment.css('p, div, li, br, blockquote, pre, tr, hr').each do |node|
      node.add_previous_sibling(' ')
      node.add_next_sibling(' ')
    end
    fragment.text.squish.truncate(200, separator: ' ')
  end
end
