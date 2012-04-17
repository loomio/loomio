module MotionsHelper
  def get_discussion_state_for(motion)
    motion.disable_discussion == false ? "checked" : ""
  end
end