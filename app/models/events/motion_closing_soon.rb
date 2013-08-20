class Events::MotionClosingSoon < Event
  after_create :notify_users!

  def self.publish!(motion)
    create!(:kind => "motion_closing_soon", :eventable => motion)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    motion.group_users.each do |user|
      if user.subscribed_to_proposal_closure_notifications
        # please do not add delayed job here.
        # this is already being called from a delayed job - rob
        UserMailer.motion_closing_soon(user, motion).deliver
      end
      notify!(user)
    end
  end
end
