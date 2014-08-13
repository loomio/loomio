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
    motion.group_members.email_when_proposal_closing_soon.each do |user|
      UserMailer.delay.motion_closing_soon(user, motion)
      notify!(user)
    end
  end
end
