module TimeZoneHelper
  
  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
  end
end