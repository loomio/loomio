require 'open-uri'

class MarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, alt_text)
    safelink = URI.escape(link).gsub(/%23/, '#')
"<a target=\"_blank\" href=\"#{safelink}\">#{alt_text}</a>"
  end

  def autolink(link, link_type)
  	debugger
    safelink = URI.escape(link).gsub(/%23/, '#')
    if link_type == :email
"<a target=\"_blank\" href=\"mailto:#{link}\">#{link}</a>"
    else
"<a target=\"_blank\" href=\"#{safelink}\">#{link}</a>"
    end
  end
end