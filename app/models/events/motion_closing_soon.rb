class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    event = create!(kind: "motion_closing_soon",
                    eventable: motion,
                    discussion_id: motion.discussion.id)

    motion.followers.
           email_followed_threads.each do |user|
      ThreadMailer.delay.new_motion(user, motion)
    end

    motion.followers.
           dont_email_followed_threads.
           email_motion_notifications_for(group).each do |user|
      ThreadMailer.delay.new_motion(user, motion)
    end

    motion.group_members_not_following.
           email_motion_notifications_for(group).each do |user|
      ThreadMailer.delay.new_motion(user, motion)
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
