require 'open-uri'

class MarkdownRenderer < Redcarpet::Render::HTML
	def link(link, title, alt_text)
	  safelink = URI.escape(link)
"<a target=\"_blank\" href=\"#{safelink}\">#{alt_text}</a>"
	end

	def autolink(link, link_type)
	  safelink = URI.escape(link)
	  if link_type == :email
"<a target=\"_blank\" href=\"mailto:#{link}\">#{link}</a>"
	  else
"<a target=\"_blank\" href=\"#{safelink}\">#{link}</a>"
	  end
	end
end