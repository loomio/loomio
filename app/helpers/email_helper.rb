module EmailHelper
  def render_email_plaintext(text)
    Rinku.auto_link(simple_format(html_escape(text)), :all, 'target="_blank"').html_safe
  end

  def render_email_markdown(text)
    markdown_email_parser.render(text).html_safe
  end

  def markdown_email_parser
    @renderer ||= EmailMarkdownRenderer.new(filter_html: true,
                                            hard_wrap: true)

    @markdown_email_parser ||= Redcarpet::Markdown.new(EmailMarkdownRenderer, autolink: true)
  end

  def mark_summary_as_read_url_for(user)
    mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                   email_timestamp: Time.now.utc.to_i)
  end
end
