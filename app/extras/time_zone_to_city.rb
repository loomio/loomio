class TimeZoneToCity
  def self.convert(iana_name)
    city_guess = iana_name.split('/')[1]
    if city_list.include? city_guess
      city_guess
    else
      offset = offset_for_iana(iana_name)
      city_from_offset(offset)
    end
  end

  def self.city_list
    ActiveSupport::TimeZone::MAPPING.keys
  end

  def self.city_from_offset(offset)
    offsets_with_city[offset]
  end

  def self.offset_for_iana(iana_name)
    ActiveSupport::TimeZone[iana_name].try(:formatted_offset) || "+00:00"
  end

  def self.offsets_with_city
    a = city_list.map { |city| [ActiveSupport::TimeZone[city].formatted_offset, city] }.flatten
    Hash[*a]
  end
end
