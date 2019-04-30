module PendingActionsHelper
  private
  def save_membership_token_in_session
    session[:pending_membership_token] = params[:membership_token] if params[:membership_token]
  end

  def handle_pending_memberships
    save_membership_token_in_session
    if current_user.is_logged_in?
      consume_pending_group(current_user)
      consume_pending_membership(current_user)
    else
      attach_pending_membership_token_to_user
    end
  end

  def attach_pending_membership_token_to_user
    current_user.membership_token = pending_membership&.token
  end

  def handle_pending_actions(user)
    return unless user.presence

    session.delete(:pending_user_id) if pending_user

    consume_pending_login_token
    consume_pending_identity(user)
    consume_pending_group(user)
    consume_pending_membership(user)
  end

  def consume_pending_login_token
    if pending_login_token
      pending_login_token.update(used: true)
      session.delete(:pending_login_token)
    end
  end

  def consume_pending_identity(user)
    if pending_identity
      user.associate_with_identity(pending_identity)
      session.delete(:pending_identity_id)
    end
  end

  def consume_pending_group(user)
    if pending_group
      membership = pending_group.memberships.build(user: user)
      MembershipService.redeem(membership: membership, actor: user)
      session.delete(:pending_group_token)
    end
  end

  def consume_pending_membership(user)
    if pending_membership
      MembershipService.redeem(membership: pending_membership, actor: user)
    end
  end

  def pending_group
    Group.find_by(token: session[:pending_group_token]) if session[:pending_group_token]
  end

  def pending_login_token
    LoginToken.find_by(token: session[:pending_login_token]) if session[:pending_login_token]
  end

  def pending_membership
    Membership.pending.find_by(token: pending_membership_token) if pending_membership_token
  end

  def pending_membership_token
    params[:membership_token] || session[:pending_membership_token]
  end

  def pending_identity
    Identities::Base.find_by(id: session[:pending_identity_id]) if session[:pending_identity_id]
  end

  def pending_user
    User.find_by(id: session[:pending_user_id]) if session[:pending_user_id]
  end

  def serialized_pending_identity
    Pending::TokenSerializer.new(pending_login_token, root: false).as_json ||
    Pending::IdentitySerializer.new(pending_identity, root: false).as_json ||
    Pending::MembershipSerializer.new(pending_membership, root: false).as_json ||
    Pending::GroupSerializer.new(pending_group, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json || {}
  end
end
