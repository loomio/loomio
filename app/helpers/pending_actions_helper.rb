module PendingActionsHelper
  private

  def handle_pending_actions
    if pending_invitation
      pending_invitation.group&.add_member!(current_user)
      session.delete(:pending_invitation_id)
    end

    if pending_identity
      current_user.identities.push(pending_identity)
      session.delete(:pending_identity_id)
    end

    if pending_user
      session.delete(:pending_user_id)
    end
  end

  def pending_invitation
    @pending_invitation ||= Invitation.find_by(id: session[:pending_invitation_id]) if session[:pending_invitation_id]
  end

  def pending_identity
    @pending_identity ||= Identities::Base.find_by(id: session[:pending_identity_id]) if session[:pending_identity_id]
  end

  def pending_user
    @pending_user ||= User.find_by(id: session[:pending_user_id]) if session[:pending_user_id]
  end
end
