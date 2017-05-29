class Events::GroupPublished < Event
  include Events::SingleCommunityEvent

  def self.publish!(group)
    return unless group.make_announcement
    create(kind: "group_published",
           user: group.creator || User.helper_bot,
           eventable: group,
           announcement: group.make_announcement,
           custom_fields: { community_id: group.community.id },
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end
end
