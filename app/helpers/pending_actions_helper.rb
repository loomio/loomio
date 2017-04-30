module PendingActionsHelper
  private

  def handle_pending_actions
    pending_invitation.group.add_member!(current_user) if pending_invitation
    current_user.identities.push(pending_identity)     if pending_identity
  end

  def pending_invitation
    @pending_invitation ||= Invitation.find_by(id: session.delete(:pending_invitation_id)) if session[:pending_invitation_id]
  end

  def pending_identity
    @pending_identity ||= Identities::Base.find_by(id: session.delete(:pending_invitation_id)) if session[:pending_identity_id]
  end
end
