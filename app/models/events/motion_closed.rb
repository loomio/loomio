class Events::MotionClosed < Event
  def self.publish!(motion)
    create(kind: 'motion_closed',
           eventable: motion,
           discussion_id: motion.discussion_id).tap { |e| Loomio::EventBus.broadcast('motion_closed_event', e) }
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
