class Events::MotionDescriptionEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_description_edited",
            eventable: motion,
            discussion_id: motion.discussion.id,
            user: editor)
  end
end
