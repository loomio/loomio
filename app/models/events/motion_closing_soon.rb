class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    event = create!(kind: "motion_closing_soon", eventable: motion)

    motion.group_members.email_when_proposal_closing_soon.each do |user|
      ThreadMailer.delay.motion_closing_soon(motion, user)
      event.notify!(user)
    end

    event
  end

  def motion
    eventable
  end
end
