class Events::GroupPublished < Event
  def self.publish!(group, identifier)
    invitation = InvitationService.shareable_invitation_for(group)
    create(kind: "group_published",
           user: group.creator || User.helper_bot,
           eventable: group,
           custom_fields: { identifier: identifier, invitation_token: invitation.token },
           created_at: group.created_at).tap { |e| EventBus.broadcast('group_published_event', e) }
  end

  def communities
    Array(eventable.community)
  end
end
