module MotionsHelper
  def motion_activity_count_for(motion, user)
    motion.number_of_votes_since_last_looked(user)
  end

  def get_motion_preview_class(motion)
    motion_class = ["motion-preview", "clearfix"]
    motion_class.join(" ")
  end

  def display_vote_buttons?(motion, user)
    motion.voting? && (not motion.user_has_voted?(user)) && motion.group.users_include?(user)
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
