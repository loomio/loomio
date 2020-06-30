module FormattedDateHelper
  def format_iso8601_for_humans(str, zone)
    format_date_for_humans(parse_date_or_datetime(str), zone)
  end

  def format_date_for_humans(date, zone = nil)
    if zone
      date.in_time_zone(zone)
    else
      date
    end.strftime(date_or_datetime_format(date)).strip
  end

  def parse_date_or_datetime(value)
    if is_datetime_string? value
      parse_datetime(value)
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

  def date_or_datetime_format(value)
    if value.is_a? DateTime
      Date.today.year == value.to_date.year ? "%a %-d %b, %H:%M" : "%a %-d %b %Y, %H:%M"
    else
      Date.today.year == value.to_date.year ? "%a %-d %b" : "%a %-d %b %Y"
    end
  end
end
