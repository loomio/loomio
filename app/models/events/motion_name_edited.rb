class Events::MotionNameEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_name_edited",
            eventable: motion,
            discussion: motion.discussion,
            user: editor)
  end
end
