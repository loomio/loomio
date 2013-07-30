class ViewLogger

  def self.motion_viewed(motion, user)
    log = MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, user.id).first
    if log.nil?
      log = MotionReadLog.new
      log.update_attributes(user_id: user.id, motion_id: motion.id)
    else
      log.update_attributes(motion_last_viewed_at: Time.now)
    end
  end
end
