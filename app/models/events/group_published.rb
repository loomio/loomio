class Events::GroupPublished < Event
  def self.publish!(group, identifier)
    create(kind: "group_published",
           user: group.creator,
           eventable: group,
           custom_fields: {identifier: identifier},
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end

  def communities
    Array(eventable.community)
  end
end
