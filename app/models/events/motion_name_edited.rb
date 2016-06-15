class Events::MotionNameEdited < Event
  def self.publish!(motion, editor)
    create(kind: "motion_name_edited",
           eventable: motion,
           user: editor).tap { |e| EventBus.broadcast('motion_name_edited_event', e) }
  end
end
