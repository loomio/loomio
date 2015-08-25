class Events::MotionDescriptionEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_description_edited",
            eventable: motion,
            user: editor)
  end

  def discussion_key
    motion.group.key
  end

  def motion
    eventable
  end
end
