class Events::NewMotion < Event
  after_create :queue_notifications_job!

  def self.publish!(motion)
    create!(:kind => "new_motion", :eventable => motion,
                      :discussion_id => motion.discussion.id)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    motion.group_users_without_motion_author.each do |user|
      if user.email_notifications_for_group?(motion.group)
        MotionMailer.new_motion_created(motion, user).deliver
      end
      notify!(user)
    end
  end

  def queue_notifications_job!
    delay.notify_users!
  end
end