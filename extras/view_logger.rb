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

  def self.discussion_viewed(discussion, user)
    log = DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, user.id).first
    if log.nil?
      log = DiscussionReadLog.new
      log.update_attributes(user_id: user.id, discussion_id: discussion.id)
    else
      log.update_attributes(discussion_last_viewed_at: Time.now)
    end
    discussion.update_total_views
  end

  def self.discussion_unfollowed(discussion, user)
    log = DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, user.id).first
    if log.nil?
      log = DiscussionReadLog.new
      log.update_attributes(user_id: user.id, discussion_id: discussion.id, following: false)
    else
      log.update_attributes(following: false)
    end
  end

  def self.group_viewed(group, user)
    membership = user.group_membership(group)
    if membership
      membership.group_last_viewed_at = Time.now
      membership.save!
    end
  end

  def self.delete_all_logs_for(user_id)
    MotionReadLog.destroy_all(user_id: user_id)
    DiscussionReadLog.destroy_all(user_id: user_id)
  end
end
