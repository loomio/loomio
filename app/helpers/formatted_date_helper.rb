module FormattedDateHelper
  def format_iso8601_for_humans(str, zone, date_time_pref)
    format_date_for_humans(parse_date_or_datetime(str), zone, date_time_pref)
  end

  def format_date_for_humans(date, zone, date_time_pref)
    format_date_or_datetime(date.in_time_zone(zone), date_time_pref)
  end

  def is_datetime?(value)
    value.is_a?(DateTime) or value.is_a?(Time) or value.is_a?(ActiveSupport::TimeWithZone)
  end

  def parse_date_or_datetime(value)
    return parse_datetime(value) if is_datetime_string?(value)
    if is_datetime?(value)
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
    when 'iso'
      date_format = '%Y-%m-%d'
      time_format = '%H:%M'
    when 'day_iso'
      date_format = '%a %Y-%m-%d'
      time_format = '%H:%M'
    when 'abbr'
      date_format = '%e %b %Y'
      time_format = '%l:%M%p'
    when 'day_abbr'
      date_format = '%a %e %b %Y'
      time_format = '%l:%M%p'
    else
      raise "unknown date pref"
    end

    if is_datetime?(value)
      value.strftime("#{date_format} #{time_format}")
    else
      value.strftime("#{date_format}")
    end
  end
end
