class Events::NewMotion < Event
  def self.publish!(motion)
    event = create!(kind: "new_motion",
                    eventable: motion,
                    discussion: motion.discussion)

    if motion.author.email_on_participation?
      DiscussionReader.for(discussion: motion.discussion,
                           user:       motion.author).change_volume! :email
    end

    ThreadMailerQuery.users_to_email_new_motion(motion).each do |user|
      ThreadMailer.delay.new_motion(user, event)
    end

    event
  end

  def motion
    eventable
  end
end
