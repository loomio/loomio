module MotionsHelper
  def motion_activity_count_for(motion, user)
    user ? user.motion_activity_count(motion) : 0
  end

  def get_motion_preview_class(motion)
    motion_class = ["motion-preview", "clearfix"]
    motion_class.join(" ")
  end
end
