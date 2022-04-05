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

  def self.render_rich_text(text, format = "md")
    return "" unless text
    if format == "md"
      text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
      MarkdownService.render_html(text)
    else
      text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
      replace_checkboxes(replace_iframes(text))
    end.html_safe
  end

  def self.render_plain_text(text, format = 'md')
    return "" unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format)).gsub(/(?:\n\r?|\r\n?)/, '<br>')
  end

  def self.replace_iframes(str)
    srcs = Nokogiri::HTML(str).search("iframe[src]").map { |el| el['src'] }
    out = str.dup
    srcs.each do |src|
      begin
        vi = VideoInfo.new(src)
        out.gsub!('<iframe src="'+src+'"></iframe>', "<a href='#{vi.url}'><img src='#{vi.thumbnail}' /></a>")
      rescue # yea, there are stupid errors to collect here.
        out.gsub!('<iframe src="'+src+'"></iframe>', "<a href='#{src}'>#{src}</a>")
      end
    end
    out
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
        node.add_child '<span class="mailer-tag">📅 '+node['data-due-on']+'</div>'
      end
    end
    frag.to_s
  end
end
