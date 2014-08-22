class Events::MotionOutcomeCreated < Event
  after_create :notify_users!

  def self.publish!(motion, user)
    create!(kind: "motion_outcome_created",
            eventable: motion,
            discussion_id: motion.discussion.id,
            user: user)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    motion.followers_without_outcome_author.
           email_followed_threads.each do |user|
      ThreadMailer.delay.motion_outcome_created(user, self)
    end

    motion.group_members_without_outcome_author.each do |user|
      notify!(user)
    end
  end

  handle_asynchronously :notify_users!
end
