class Events::MotionClosed < Event
  after_create :notify_users!

  def self.publish!(motion, closer)
    create!(:kind => "motion_closed", :eventable => motion, :user => closer,
                      :discussion_id => motion.discussion.id)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    MotionMailer.motion_closed(motion, motion.author.email).deliver
    motion.group_users.each do |group_user|
      unless group_user == user
        notify!(group_user)
      end
    end
  end

  handle_asynchronously :notify_users!
end
