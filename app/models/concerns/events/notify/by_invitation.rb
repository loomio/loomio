module Events::Notify::ByInvitation
  def trigger!
    super
    email_invitations!
  end

  # send event emails
  def email_invitations!
    Events::InvitationCreated.bulk_publish!(invitation_recipients, user)
  end
  handle_asynchronously :email_invitations!

  private

  # which invitations should be sent from this event?
  # (NB: This must return an ActiveRecord::Relation)
  def invitation_recipients
    Invitation.none
  end
end
