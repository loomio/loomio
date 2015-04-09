class Events::NewMotion < Event
  def self.publish!(motion)
    event = create!(kind: "new_motion",
                    eventable: motion,
                    discussion: motion.discussion)

    DiscussionReader.for(discussion: motion.discussion,
                         user: motion.author).
                     set_volume_as_required!

    UsersToEmailQuery.new_motion(motion).find_each do |user|
      ThreadMailer.delay.new_motion(user, event)
    end

    motion.discussion.webhooks.each do |webhook|
      WebhookService.publish! webhook: webhook, event: event
    end

    event
  end

  def motion
    eventable
  end
end
