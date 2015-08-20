class Events::MotionClosed < Event
  def self.publish!(motion)
    event = create!(kind: 'motion_closed',
                    eventable: motion,
                    discussion_id: motion.discussion_id)

    UsersToEmailQuery.motion_closed(motion).find_each do |user|
      ThreadMailer.delay.motion_closed(user, event)
    end

    event.notify! motion.author
    event
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
