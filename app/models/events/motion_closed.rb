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
    MotionMailer.delay.motion_closed(motion, motion.author.email)

    motion.group_members.each do |group_user|
      notify!(group_user)
    end
  end

  handle_asynchronously :notify_users!
end
