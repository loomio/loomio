class Events::MotionOutcomeCreated < Event
  after_create :notify_users!

  def self.publish!(motion, user)
    create!(kind: "motion_outcome_created",
            eventable: motion,
            discussion: motion.discussion,
            user: user)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    UsersToEmailQuery.motion_outcome(motion).find_each do |user|
      ThreadMailer.delay.motion_outcome_created(user, self)
    end

    UsersByVolumeQuery.normal_or_loud(discussion).without(motion.outcome_author).find_each do |user|
      notify!(user)
    end
  end

  handle_asynchronously :notify_users!
end
