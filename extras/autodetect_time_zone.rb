module AutodetectTimeZone
  private
  def set_time_zone_from_javascript
    detected_time_zone = request.cookies["time_zone"]
    if detected_time_zone.present? and detected_time_zone != 'undefined' and current_user
      if detected_time_zone != current_user.time_zone
        current_user.update_attribute(:time_zone, detected_time_zone)
      end
    end
  end
end
