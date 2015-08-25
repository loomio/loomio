class Events::MotionDescriptionEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_description_edited",
            eventable: motion,
            user: editor,
            discussion_id: motion.discussion_id)
  end

  def discussion_key
    motion.group.key
  end

  def motion
    eventable
  end
end
