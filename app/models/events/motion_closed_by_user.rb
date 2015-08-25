class Events::MotionClosedByUser < Events::MotionClosed
  def self.publish!(motion, closer)
    create!(kind: "motion_closed_by_user",
            eventable: motion,
            user: closer)
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
