class Events::MotionClosed < Event
  def self.publish!(motion)
    event = create!(kind: 'motion_closed', eventable: motion)

    ThreadMailerQuery.users_with_volume_email(motion.discussion).each do |user|
      ThreadMailer.delay.motion_closed(user, event)
    end

    event.notify! motion.author
    event
  end

  def motion
    eventable
  end
end
