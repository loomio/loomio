module AutodetectTimeZone
  private
  def set_time_zone_from_javascript
    if params[:javascript_time_zone].present? and params[:javascript_time_zone] != 'undefined' and current_user
      current_user.update_attribute(:time_zone, params[:javascript_time_zone])
    end
  end
end
