class Events::MotionOutcomeUpdated < Event

  def self.publish!(motion, user)
    create!(kind: "motion_outcome_updated",
            eventable: motion,
            discussion: motion.discussion,
            user: user)
  end

  def motion
    eventable
  end
end
