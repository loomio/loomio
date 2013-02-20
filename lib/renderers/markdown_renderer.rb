require 'open-uri'

class MarkdownRenderer < Redcarpet::Render::HTML
  def initialize
    super(:filter_html => true, :hard_wrap => true)
  end

  def link(link, title, alt_text)
    if link
      safelink = URI.escape(link).gsub(/%23/, '#')
      "<a target=\"_blank\" href=\"#{safelink}\">#{alt_text}</a>"
    else
      "<a href=\"#\">#{alt_text}</a>"
    end
  end

  def autolink(link, link_type)
    safelink = URI.escape(link).gsub(/%23/, '#')
    if link_type == :email
      "<a target=\"_blank\" href=\"mailto:#{link}\">#{link}</a>"
    else
      "<a target=\"_blank\" href=\"#{safelink}\">#{link}</a>"
    end
  end
end