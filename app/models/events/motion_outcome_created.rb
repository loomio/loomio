class Events::MotionOutcomeCreated < Event
  include Events::LiveUpdate
  include Events::NotifyUser
  include Events::EmailUser
  include Events::JoinDiscussion

  def self.publish!(motion)
    create(kind: "motion_outcome_created",
           eventable: motion,
           discussion: motion.discussion,
           user: motion.outcome_author).tap { |e| EventBus.broadcast('motion_outcome_created_event', e) }
  end

  private

  def notification_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable.discussion).without(eventable.outcome_author)
  end
  alias :email_recipients :notification_recipients

  def notification_actor
    eventable.outcome_author
  end
end
