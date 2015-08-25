class Events::MotionNameEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_name_edited",
            eventable: motion,
            user: editor,
            discussion_id: motion.discussion_id)
  end

  def group_key
    motion.group.key
  end

  def motion
    eventable
  end
end
