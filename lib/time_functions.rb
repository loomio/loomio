module TimeFunctions
  def local_time(this_time)
    Time.zone.utc_to_local(this_time)
  end
end
