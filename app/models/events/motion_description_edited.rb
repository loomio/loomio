class Events::MotionDescriptionEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_description_edited",
            eventable: motion,
            discussion: motion.discussion,
            user: editor)
  end
end
