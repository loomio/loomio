module MotionsHelper
  def motion_sparkline(motion)
    values = motion.vote_counts.values
    if values.sum == 0
      '0,0,0,0,1'
    else
      values.join(',')
    end
  end

  def display_vote_buttons?(motion, user)
    motion.voting? && (not motion.user_has_voted?(user))
  end

  def time_select_options
    time_select = []
    midnight = "2010-01-01 00:00".to_time
    (0..23).map do |hour|
      time = midnight + hour.hours
      [time.strftime("%l %P"), time.strftime("%H:00")]
    end
  end
end
