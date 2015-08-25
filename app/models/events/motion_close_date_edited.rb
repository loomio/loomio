class Events::MotionCloseDateEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_close_date_edited",
            eventable: motion,
            user: editor)
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
