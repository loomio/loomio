class Events::GroupPublished < Event
  include Events::Notify::ThirdParty

  def self.publish!(group, actor)
    return unless group.make_announcement
    create(kind: "group_published",
           user: actor,
           eventable: group,
           announcement: group.make_announcement,
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end
end
