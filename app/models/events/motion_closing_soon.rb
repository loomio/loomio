class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    event = create!(kind: "motion_closing_soon",
                    eventable: motion)

    UsersToEmailQuery.motion_closing_soon(motion).find_each do |user|
      ThreadMailer.delay.motion_closing_soon(user, event)
    end

    motion.group_members.each do |member|
      event.notify!(member)
    end

    event
  end

  def motion
    eventable
  end
end
