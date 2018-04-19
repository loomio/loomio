module FormattedDateHelper
  def display_time(value, zone)
    apply_format parse_date_string(value, zone), '%l:%M %P'
  end

  def display_day(value, zone)
    apply_format parse_date_string(value, zone), '%a'
  end

  def display_date(value, zone)
    apply_format parse_date_string(value, zone), '%-d %b'
  end

  def has_time?(value)
    !!date_time(value)
  rescue ArgumentError
    false
  end

  private

  def parse_date_string(value, zone)
    if has_time? value
      date_time(value).in_time_zone(zone)
    else
      value.to_date
    end
  end

  def apply_format(date, format)
    date.strftime(format).strip
  end

  def formatted_datetime(value, zone)
    if has_time? value
      date_time(value).in_time_zone(zone).strftime(date_time_format(value)).strip
    else
      value.to_date.strftime(date_format(value)).strip
    end
  end

  def date_time(value)
    DateTime.strptime(value.sub('.000Z', 'Z'))
  end

  def date_time_format(value)
    Date.today.year == value.to_date.year ? "%a %-d %b %l:%M %P" : "%a %-d %b %Y %l:%M %P"
  end

  def date_format(value)
    Date.today.year == value.to_date.year ? "%a %-d %b" : "%a %-d %b %Y"
  end
end
