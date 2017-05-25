class Events::GroupPublished < Event
  def self.publish!(group)
    invitation = InvitationService.shareable_invitation_for(group)
    create(kind: "group_published",
           user: group.creator || User.helper_bot,
           eventable: group,
           announcement: group.make_announcement,
           custom_fields: {
             identifier:       group.community.slack_channel_id,
             invitation_token: invitation.token
           },
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end

  def communities
    return [] unless self.announcement
    Array(eventable.community)
  end
end
