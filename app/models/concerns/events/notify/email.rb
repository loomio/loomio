module Events::Notify::Email
  def trigger!
    super
    email_invitations!
  end

  # create invitation events
  def email_invitations!
    invitation_recipients.each do |recipient|
      InvitationService.create(invitation: invitation_for(recipient), actor: user)
    end
  end
  handle_asynchronously :email_invitations!

  private

  def invitation_for(email)
    Invitation.new(
      recipient_email: email,
      group:           eventable.guest_group,
      intent:          :"join_#{eventable.class.to_s.downcase}"
    )
  end

  # which users should receive an invitation to this eventable?
  def invitation_recipients
    []
  end

end
