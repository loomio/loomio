class Events::MotionClosingSoon < Event
  def self.publish!(motion)
    event = create!(kind: "motion_closing_soon",
                    eventable: motion,
                    discussion: motion.discussion)

    motion.followers.
           email_followed_threads.each do |user|
      ThreadMailer.delay.motion_closing_soon(user, event)
    end

    motion.followers.
           dont_email_followed_threads.
           email_when_proposal_closing_soon.each do |user|
      ThreadMailer.delay.motion_closing_soon(user, event)
    end

    motion.group_members_not_following.
           email_when_proposal_closing_soon.each do |user|
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
