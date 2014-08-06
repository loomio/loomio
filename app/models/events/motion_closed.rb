class Events::MotionClosed < Event
  after_create :notify_users!

  def self.publish!(motion)
    create!(:kind => "motion_closed", :eventable => motion, :discussion_id => motion.discussion.id)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    UserMailer.delay.motion_closed(motion, motion.author.email)
    notify! motion.author
  end

  handle_asynchronously :notify_users!
end
