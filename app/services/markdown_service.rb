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

  def self.render_markdown(text, format = 'md')
    text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
    text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')

    if format == "md"
      text
    else
      ReverseMarkdown.convert(text)
    end
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
      begin
        vi = VideoInfo.new(node['src'])
        container = Nokogiri::XML::Node.new('div', doc.document)
        link = Nokogiri::XML::Node.new('a', doc.document)
        image = Nokogiri::XML::Node.new('img', doc.document)
        link['href'] = vi.url.to_s
        image['src'] = vi.thumbnail.to_s
        link.add_child(image)
        container.add_child(link)
        node.replace(container)
      rescue
        link = Nokogiri::XML::Node.new('a', doc.document)
        link['href'] = node['src']
        link.add_child(Nokogiri::XML::Text.new(node['src'], doc.document))
        node.replace(link)
      end
    end
    doc.to_s
  end

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
        due_on['class'] = 'mailer-tag'
        due_on.add_child(Nokogiri::XML::Text.new("📅 #{node['data-due-on']}", frag.document))
        node.add_child(due_on)
      end
    end
    frag.to_s
  end
end
