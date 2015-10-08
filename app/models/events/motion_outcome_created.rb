class Events::MotionOutcomeCreated < Event
  def self.publish!(motion, user)
    event = create!(kind: "motion_outcome_created",
            eventable: motion,
            discussion: motion.discussion,
            user: user)

    BaseMailer.send_bulk_mail(to: UsersToEmailQuery.motion_outcome(motion)) do |user|
      ThreadMailer.delay.motion_outcome_created(user, event)
    end

    UsersByVolumeQuery.normal_or_loud(motion.discussion).without(motion.outcome_author).find_each do |user|
      event.notify!(user)
    end

    event
  end
end
