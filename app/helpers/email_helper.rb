module EmailHelper
  def reply_to_address(discussion: discussion, user: user)
    pairs = []
    {d: discussion.id, u: user.id, k: user.email_api_key}.each do |key, value|
      pairs << "#{key}=#{value}"
    end
    pairs.join('&')+"@#{ENV['REPLY_HOSTNAME']}"
  end

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

  def mark_summary_as_read_url_for(user, format: nil)
    mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                   time_start: @time_start.utc.to_i,
                                   time_finish: @time_finish.utc.to_i,
                                   format: format)
  end
end
