class AcceptInvitation
  def self.and_grant_access!(invitation, user)
    invitation.accepted_by = user
    invitation.accepted_at = DateTime.now
    if invitation.to_be_admin?
      invitation.group.add_admin!(user, invitation.inviter)
    else
      invitation.group.add_member!(user, invitation.inviter)
    end
  end
end
