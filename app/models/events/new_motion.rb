class Events::NewMotion < Event
  def self.publish!(motion)
    event = create!(kind: "new_motion",
                    eventable: motion,
                    discussion_id: motion.discussion.id)

    DiscussionReader.for(discussion: motion.discussion,
                         user: motion.author).follow!

    motion.followers_without_author.
           email_followed_threads.each do |user|
      ThreadMailer.delay.new_motion(user, motion)
    end

    motion.followers_without_author.
           dont_email_followed_threads.
           email_motion_notifications_for(motion.group).each do |user|
      ThreadMailer.delay.new_motion(user, motion)
    end

    motion.group_members_not_following.
           email_motion_notifications_for(motion.group).each do |user|
      ThreadMailer.delay.new_motion(user, motion)
    end

    event
  end

  def motion
    eventable
  end
end
