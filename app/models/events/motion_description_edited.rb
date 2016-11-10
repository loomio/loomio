class Events::MotionDescriptionEdited < Event
  def self.publish!(motion, editor)
    create(kind: "motion_description_edited",
           eventable: motion,
           user: editor).tap { |e| EventBus.broadcast('motion_description_edited_event', e) }
  end
end
