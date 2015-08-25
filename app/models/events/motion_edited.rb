class Events::MotionEdited < Event
  def self.publish!(motion, editor)
    record_edit = RecordEdit.capture!(motion, editor)
    create!(kind: "motion_edited",
            eventable: record_edit,
            user: editor,
            discussion_id: motion.discussion_id)
  end

  def group_key
    discussion.group.key
  end
end
