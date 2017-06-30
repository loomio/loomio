class Events::GroupPublished < Event
  include Events::Notify::ThirdParty

  def self.publish!(group, actor, identity_id)
    return unless group.make_announcement
    create(kind: "group_published",
           user: actor,
           eventable: group,
           custom_fields: {identity_id: identity_id},
           announcement: group.make_announcement,
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end
end
