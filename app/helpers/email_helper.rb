module EmailHelper
  def reply_to_address(discussion: , user: )
    pairs = []
    {d: discussion.id, u: user.id, k: user.email_api_key}.each do |key, value|
      pairs << "#{key}=#{value}"
    end
    pairs.join('&')+"@#{ENV['REPLY_HOSTNAME']}"
  end

  def reply_to_address_with_group_name(discussion: , user: )
    "\"#{discussion.group.full_name}\" <#{reply_to_address(discussion: discussion, user: user)}>"
  end

  def render_email_plaintext(text)
    Rinku.auto_link(simple_format(html_escape(text)), :all, 'target="_blank"').html_safe
  end

  def render_email_markdown(text)
    markdown_email_parser.render(text).html_safe
  end

  def markdown_email_parser
    Redcarpet::Markdown.new(EmailMarkdownRenderer, autolink: true)
  end

  def mark_summary_as_read_url_for(user, format: nil)
    email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                 time_start: @time_start.utc.to_i,
                                                 time_finish: @time_finish.utc.to_i,
                                                 format: format)
  end

  def comment_url_helper(comment)
    discussion_url(comment.discussion, @utm_hash.merge(anchor: "comment-#{comment.id}"))
  end

  def vote_icon_paths_helper(position)
    asset_url "hand-#{position}-18.png"
  end

  def motion_closing_time_for(user)
    @motion.closing_at.in_time_zone(TimeZoneToCity.convert user.time_zone).strftime('%A %-d %b - %l:%M%P')
  end
end
