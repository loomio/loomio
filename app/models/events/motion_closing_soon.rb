class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    event = create!(kind: "motion_closing_soon",
                    eventable: motion)

    BaseMailer.send_bulk_mail(to: UsersToEmailQuery.motion_closing_soon(motion)) do |user|
      ThreadMailer.delay.motion_closing_soon(user, event)
    end

    UsersByVolumeQuery.normal_or_loud(motion.discussion).find_each do |user|
      event.notify!(user)
    end

    event
  end

  def motion
    eventable
  end
end
