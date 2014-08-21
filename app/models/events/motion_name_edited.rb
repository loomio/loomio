class Events::MotionNameEdited < Event
  def self.publish!(motion, editor)
    create!(kind: "motion_name_edited",
            eventable: motion,
            discussion_id: motion.discussion.id,
            user: editor)
  end
end
