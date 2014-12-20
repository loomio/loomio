module EmailHelper
  def reply_to_address(discussion: discussion, user: user)
    pairs = []
    {d: discussion.id, u: user.id, k: user.email_api_key}.each do |key, value|
      pairs << "#{key}=#{value}"
    end
    pairs.join('&')+"@#{ENV['REPLY_HOSTNAME']}"
  end

  def reply_to_address_with_group_name(discussion: discussion, user: user)
    "\"#{discussion.group.full_name}\" <#{reply_to_address(discussion: discussion, user: user)}>"
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
    email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                 time_start: @time_start.utc.to_i,
                                                 time_finish: @time_finish.utc.to_i,
                                                 format: format)
  end

  def comment_url_helper(comment)
    discussion_url(comment.discussion, @utm_hash.merge(anchor: "comment-#{comment.id}"))
  end

  def vote_icon_paths_helper(position)
    asset_path "hand-#{position}-18.png"

    #case position
     #when 'yes'
       #"https://loomio-attachments.s3.amazonaws.com/themes/pages_logos/000/000/005/original/hand-yes-18.png?1403064691"
     #when 'no'
       #"https://loomio-attachments.s3.amazonaws.com/themes/app_logos/000/000/005/original/hand-no-18.png?1403064711"
     #when 'block'
       #"https://loomio-attachments.s3.amazonaws.com/themes/pages_logos/000/000/004/original/hand-block-18.png?1403064137"
     #when 'abstain'
       #"https://loomio-attachments.s3.amazonaws.com/themes/app_logos/000/000/004/original/hand-abstain-18.png?1403064137"
     #end
  end

  def motion_closing_time_for(user)
    @motion.closing_at.in_time_zone(TimeZoneToCity.convert user.time_zone).strftime('%A %-d %b - %l:%M%P')
  end
end
