module PendingActionsHelper
  private

  def handle_pending_actions(user)
    return unless user.presence

    if pending_token
      pending_token.update(used: true)
      session.delete(:pending_token)
    end

    if pending_invitation
      InvitationService.redeem(pending_invitation, user)
      session.delete(:pending_invitation_id)
    end

    if pending_identity
      user.associate_with_identity(pending_identity)
      session.delete(:pending_identity_id)
    end

    if pending_user
      session.delete(:pending_user_id)
    end
  end

  def pending_token
    @pending_token_user ||= LoginToken.find_by!(token: session[:pending_token]) if session[:pending_token]
  end

  def pending_invitation
    @pending_invitation ||= Invitation.find_by(token: session[:pending_invitation_id]) if session[:pending_invitation_id]
  end

  def pending_identity
    @pending_identity ||= Identities::Base.find_by(id: session[:pending_identity_id]) if session[:pending_identity_id]
  end

  def pending_user
    @pending_user ||= User.find_by(id: session[:pending_user_id]) if session[:pending_user_id]
  end

  def serialized_pending_identity
    Pending::TokenSerializer.new(pending_token, root: false).as_json ||
    Pending::IdentitySerializer.new(pending_identity, root: false).as_json ||
    Pending::InvitationSerializer.new(pending_invitation, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json
  end
end
