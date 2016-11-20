class Events::MotionClosed < Event
  def self.publish!(motion)
    create(kind: 'motion_closed',
           eventable: motion,
           discussion_id: motion.discussion_id).tap { |e| EventBus.broadcast('motion_closed_event', e, motion.author) }
  end

  private

  def notification_url
    discussion_motion_outcome_path(eventable.discussion, eventable)
  end

  def notification_translation_values
    super.merge(publish_outcome: true)
  end

  def notification_actor
    nil
  end
end
