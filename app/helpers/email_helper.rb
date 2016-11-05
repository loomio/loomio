module EmailHelper
  include PrettyUrlHelper

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

  def mark_summary_as_read_url_for(user, format: nil)
     email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                  time_start: @time_start.utc.to_i,
                                                  time_finish: @time_finish.utc.to_i,
                                                  format: format)
  end

  def motion_closing_time_for(user)
    @motion.closing_at.in_time_zone(TimeZoneToCity.convert user.time_zone).strftime('%A %-d %b - %l:%M%P')
  end

  def motion_sparkline(motion)
    values = motion.vote_counts.values
    if values.sum == 0
      '0,0,0,0,1'
    else
      values.join(',')
    end
  end

  def time_formatted_relative_to_age(time)
    current_time = Time.zone.now
    if time.to_date == Time.zone.now.to_date
      l(time, format: :for_today)
    elsif time.year != current_time.year
      l(time.to_date, format: :for_another_year)
    else
      l(time.to_date, format: :for_this_year)
    end
  end
end
