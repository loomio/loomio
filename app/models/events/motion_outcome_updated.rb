class Events::MotionOutcomeUpdated < Event
  include Events::JoinDiscussion

  def self.publish!(motion, user)
    create(kind: "motion_outcome_updated",
           eventable: motion,
           discussion: motion.discussion,
           user: user).tap { |e| EventBus.broadcast('motion_outcome_updated_event', e) }
  end
end
