module EmailHelper
  include PrettyUrlHelper

  def formatted_datetime_for(date_string, zone)
    date_time = DateTime.strptime(date_string.sub('.000Z', 'Z')).in_time_zone(zone)
    date_time.strftime(date_time.year == Date.today.year ? "%e %b %l:%M %P" : "%e %b %Y %l:%M %P")
  rescue ArgumentError
    formatted_date_for(date_string)
  end

  def formatted_date_for(date_string)
    date = date_string.to_date
    date.strftime(date.year == Date.today.year ? "%e %b" : "%e %b %Y")
  end

  def format_poll_option_name(poll_option, zone)
    poll_option.poll.dates_as_options ? formatted_datetime_for(poll_option.name, zone) : poll_option.name
  end

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

  def formatted_time_in_zone(time, zone)
    return unless time && zone
    time.in_time_zone(TimeZoneToCity.convert zone).strftime('%l:%M%P - %A %-d %b %Y')
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

  def google_pie_chart_url(poll)
    sparkline = proposal_sparkline(poll)
    colors = poll_color_values(poll.poll_type).map { |color| color.sub('#', '') }.join('|')
    URI.escape("https://chart.googleapis.com/chart?cht=p&chma=0,0,0,0|0,0&chs=200x200&chd=t:#{sparkline}&chco=#{colors}")
  end

  def poll_color_values(poll_type)
    Poll::COLORS.fetch(poll_type, [])
  end

  def proposal_sparkline(poll)
    poll.stance_counts.join(',')
  end

  def percentage_for(poll, index)
    if poll.stance_counts.max.to_i <= 0
      0
    else
      (100 * poll.stance_counts[index].to_f / poll.stance_counts.max).to_i
    end
  end

  def dot_vote_stance_choice_percentage_for(stance, stance_choice)
    max = stance.poll.custom_fields['dots_per_person'].to_i
    if max <= 0
      0
    else
      (100 * stance_choice.score.to_f / max).to_i
    end
  end
end
