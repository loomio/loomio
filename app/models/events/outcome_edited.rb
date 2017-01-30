class Events::OutcomeEdited < Event
  def self.publish!(version, actor)
    create(kind: "outcome_edited",
           user: actor,
           eventable: version,
           discussion: version.item.discussion,
           created_at: version.created_at).tap { |e| EventBus.broadcast('outcome_edited_event', e) }
  end
end
