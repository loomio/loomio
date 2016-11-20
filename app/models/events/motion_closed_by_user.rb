class Events::MotionClosedByUser < Events::MotionClosed
  def self.publish!(motion, closer)
    create(kind: "motion_closed_by_user",
           eventable: motion,
           discussion_id: motion.discussion_id,
           user: closer).tap { |e| EventBus.broadcast('motion_closed_by_user_event', e) }
  end

  private

  def notification_translation_values
    super.merge(publish_outcome: true)
  end

  def notification_url
    discussion_motion_outcome_url(eventable.discussion, eventable)
  end
end
