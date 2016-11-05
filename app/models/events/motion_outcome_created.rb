class Events::MotionOutcomeCreated < Event
  def self.publish!(motion, user)
    create(kind: "motion_outcome_created",
           eventable: motion,
           discussion: motion.discussion,
           user: user).tap { |e| EventBus.broadcast('motion_outcome_created_event', e) }
  end

  def users_to_notify
    Queries::UsersByVolumeQuery.normal_or_loud(discussion).without(eventable.outcome_author)
  end

  private

  def notification_actor
    eventable.outcome_author
  end
end
