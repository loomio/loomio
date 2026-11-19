module MarkdownService
  MARKDOWN_PUNCTUATION = Regexp.union("\\", "`", "*", "_", "[", "]", "{", "}", "(", ")", "#", "+", "-", ".", "!", "|", "<", ">", "~")

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

  def self.render_markdown(text, format = 'md')
    text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
    text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')

    if format == "md"
      text
    else
      ReverseMarkdown.convert(text)
    end
  end

  # Keep a user-controlled inline label as text when it is inserted into a
  # larger Markdown document. Newlines are collapsed so the value cannot start
  # a new block, and Markdown punctuation loses its markup meaning.
  def self.escape_inline(text)
    text.to_s.gsub(/\r\n?|\n/, " ").gsub(MARKDOWN_PUNCTUATION) { |character| "\\#{character}" }
  end

  def self.render_html(text)
    return '' if text.nil?
    renderer = LoomioMarkdown.new(filter_html: true, hard_wrap: true, link_attributes: {rel: "nofollow ugc noreferrer noopener", target: :_blank})
    Redcarpet::Markdown.new(renderer, *MARKDOWN_OPTIONS).render(text)
  end

  def self.render_rich_text(text, format = "md")
    return "".html_safe unless text
    text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
    text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
    if format == "md"
      MarkdownService.render_html(text)
    else
      replace_audios(replace_videos(replace_checkboxes(replace_iframes(text))))
    end.html_safe
  end

  # stripped of any user generated html
  # newlines converted to brs
  # Readable plain text for link previews and structured data: no headings,
  # paragraphs kept apart, whitespace collapsed, cut at a word boundary.
  def self.render_excerpt(text, format = 'md', length: 200)
    return "" if text.blank?
    html = format == 'md' ? render_html(text) : text.to_s
    fragment = Nokogiri::HTML5.fragment(html)
    fragment.css('h1, h2, h3, h4, h5, h6, script, style').remove
    fragment.css('p, div, li, br, blockquote, pre, tr, hr').each do |node|
      node.add_previous_sibling(' ')
      node.add_next_sibling(' ')
    end
    fragment.text.squish.truncate(length, separator: ' ')
  end

  def self.render_plain_text(text, format = 'md')
    return "".html_safe unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format)).gsub(/(?:\n\r?|\r\n?)/, '<br>').html_safe
  end

  def self.replace_videos(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("video[src]").each do |node|
      paragraph = Nokogiri::XML::Node.new('p', doc.document)
      link = Nokogiri::XML::Node.new('a', doc.document)
      image = Nokogiri::XML::Node.new('img', doc.document)
      link['href'] = node['src']
      image['src'] = node['poster'].to_s
      link.add_child(image)
      link.add_child(Nokogiri::XML::Node.new('br', doc.document))
      link.add_child(Nokogiri::XML::Text.new(I18n.t('record_modal.watch_video'), doc.document))
      paragraph.add_child(link)
      node.replace(paragraph)
    end
    doc.to_s
  end

  def self.replace_audios(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("audio[src]").each do |node|
      paragraph = Nokogiri::XML::Node.new('p', doc.document)
      link = Nokogiri::XML::Node.new('a', doc.document)
      link['href'] = node['src']
      link.add_child(Nokogiri::XML::Text.new(I18n.t('record_modal.listen_to_audio'), doc.document))
      paragraph.add_child(link)
      node.replace(paragraph)
    end
    doc.to_s
  end

  def self.replace_iframes(str)
    doc = Nokogiri::HTML5::DocumentFragment.parse(str)
    doc.search("iframe[src]").each do |node|
      link = Nokogiri::XML::Node.new('a', doc.document)
      if (id = youtube_video_id(node['src']))
        link['href'] = "https://www.youtube.com/watch?v=#{id}"
        image = Nokogiri::XML::Node.new('img', doc.document)
        image['src'] = "https://i.ytimg.com/vi/#{id}/hqdefault.jpg"
        image['alt'] = I18n.t('record_modal.watch_video')
        link.add_child(image)
      else
        link['href'] = node['src']
        link.add_child(Nokogiri::XML::Text.new(node['src'], doc.document))
      end
      node.replace(link)
    end
    doc.to_s
  end

  # YouTube thumbnails are determined by the video ID; rendering needs no
  # metadata request. Exact hosts and IDs keep arbitrary URLs out of previews.
  def self.youtube_video_id(url)
    uri = URI.parse(url)
    return unless uri.scheme.nil? || %w[http https].include?(uri.scheme)

    id = case uri.host&.downcase
    when 'youtu.be', 'www.youtu.be'
      uri.path.delete_prefix('/').delete_suffix('/')
    when 'youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtube-nocookie.com', 'www.youtube-nocookie.com'
      if uri.path == '/watch'
        URI.decode_www_form(uri.query.to_s).to_h['v']
      else
        uri.path[%r{\A/(?:embed|shorts|live|v)/([^/]+)/?\z}, 1]
      end
    end
    id if /\A[a-zA-Z0-9_-]{11}\z/.match?(id.to_s)
  rescue URI::InvalidURIError, ArgumentError
    nil
  end
  private_class_method :youtube_video_id

  def self.replace_checkboxes(str)
    frag = Nokogiri::HTML::DocumentFragment.parse(str)
    frag.css('li[data-type="taskItem"]').each do |node|
      if node['data-checked'] == 'true'
        node.prepend_child '<div class="email-checkbox">✔️</div>'
      else
        node.prepend_child '<div class="email-checkbox">&nbsp;</div>'
      end

      if node['data-due-on']
        due_on = Nokogiri::XML::Node.new('span', frag.document)
        due_on['class'] = 'email-tag'
        due_on.add_child(Nokogiri::XML::Text.new("📅 #{node['data-due-on']}", frag.document))
        node.add_child(due_on)
      end
    end
    frag.to_s
  end
end
