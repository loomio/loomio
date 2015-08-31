class Events::NewMotion < Event
  def self.publish!(motion)
    event = create!(kind: "new_motion",
                    eventable: motion,
                    discussion: motion.discussion,
                    created_at: motion.created_at)

    UsersToEmailQuery.new_motion(motion).find_each do |user|
      ThreadMailer.delay.new_motion(user, event)
    end

    event
  end

  def group_key
    discussion.group.key
  end

  def motion
    eventable
  end
end
