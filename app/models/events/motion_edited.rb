class Events::MotionEdited < Event
  def self.publish!(motion, editor)
    version = motion.versions.last
    create!(kind: "motion_edited",
            eventable: version,
            user: editor,
            discussion_id: motion.discussion_id)
  end

  def group_key
    discussion.group.key
  end
end
