module FormattedDateHelper
  def format_iso8601_for_humans(str, zone, date_time_pref)
    format_date_for_humans(parse_date_or_datetime(str), zone, date_time_pref)
  end

  def format_date_for_humans(date, zone = nil, date_time_pref)
    if zone
      date.in_time_zone(zone)
    else
      date
    end.strftime(format_date_or_datetime(date, date_time_pref)).strip
  end

  def parse_date_or_datetime(value)
    return parse_datetime(value) if is_datetime_string?(value)
    if value.is_a?(DateTime) or value.is_a?(Time) or value.is_a?(ActiveSupport::TimeWithZone)
      value 
    else
      value.to_date
    end
  end

  def is_datetime_string?(value)
    !!parse_datetime(value)
  rescue ArgumentError
    false
  end

  def parse_datetime(value)
    DateTime.strptime(value.sub('.000Z', 'Z'))
  end

  def format_date_or_datetime(value, date_time_pref)
    case date_time_pref
    when 'day_abbr'
      date_format = '%a %e %b %Y'
      time_format = '%l:%M%p'
    when 'abbr'
      date_format = '%e %b %Y'
      time_format = '%l:%M%p'
    when 'day_iso'
      date_format = '%a %Y-%m-%d'
      time_format = '%H:%M'
    else #iso
      date_format = '%Y-%m-%d'
      time_format = '%H:%M'
    end

    if value.is_a? DateTime
      value.strftime("#{date_format} #{time_format}")
    else
      value.strftime("#{date_format}")
    end
  end
end
