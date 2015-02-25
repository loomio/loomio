class AcceptInvitation
  def self.and_grant_access!(invitation, user)
    invitation.accepted_by = user
    invitation.accepted_at = DateTime.now
    if invitation.to_be_admin?
      membership = invitation.group.add_admin!(user, invitation.inviter)
    else
      membership = invitation.group.add_member!(user, invitation.inviter)
    end
    invitation.save!
    Events::InvitationAccepted.publish!(membership)
  end
end
