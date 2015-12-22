class Events::MotionClosedByUser < Events::MotionClosed
  def self.publish!(motion, closer)
    create(kind: "motion_closed_by_user",
           eventable: motion,
           discussion_id: motion.discussion_id,
           user: closer).tap { |e| EventBus.broadcast('motion_closed_by_user_event', e) }
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
