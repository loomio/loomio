module PendingActionsHelper
  private

  def handle_pending_actions(user)
    return unless user.presence

    if pending_token
      pending_token.update(used: true)
      session.delete(:pending_token)
    end

    if pending_membership
      MembershipService.redeem(membership: pending_membership, actor: user)
      session.delete(:pending_membership_token)
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
    @pending_token_user ||= LoginToken.where.not(user_id: current_user.email_verified? && current_user.id).find_by(token: session[:pending_token]) if session[:pending_token]
  end

  def pending_membership
    @pending_membership ||= Membership.find_by(token: session[:pending_membership_token]) if session[:pending_membership_token]
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
    Pending::MembershipSerializer.new(pending_membership, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json || {}
  end
end
