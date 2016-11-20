class Events::MotionEdited < Event
  def self.publish!(motion, editor)
    create(kind: "motion_edited",
           eventable: motion.versions.last,
           user: editor,
           discussion_id: motion.discussion_id).tap { |e| EventBus.broadcast('motion_edited_event', e) }
  end
end
