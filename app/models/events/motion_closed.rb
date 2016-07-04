class Events::MotionClosed < Event
  def self.publish!(motion)
    create(kind: 'motion_closed',
           eventable: motion,
           discussion_id: motion.discussion_id).tap { |e| EventBus.broadcast('motion_closed_event', e, motion.author) }
  end
end
