module PendingActionsHelper
  private
  def handle_pending_actions(user = current_user)
    if params[:membership_token]
      session[:pending_membership_token] = params[:membership_token]
      user.membership_token = params[:membership_token]
    end

    if params[:discussion_reader_token]
      session[:pending_discussion_reader_token] = params[:discussion_reader_token]
      user.discussion_reader_token = params[:discussion_reader_token]
    end

    if params[:stance_token]
      session[:pending_stance_token] = params[:stance_token]
      user.stance_token = params[:stance_token]
    end

    if user.is_logged_in?
      session.delete(:pending_user_id) if pending_user
      consume_pending_login_token
      consume_pending_identity(user)
      consume_pending_group(user)
      consume_pending_membership(user)
      consume_pending_discussion_reader(user)
      consume_pending_stance(user)
    end
  end

  def consume_pending_login_token
    pending_login_token.update(used: true) if pending_login_token
    session.delete(:pending_login_token)
  end

  def consume_pending_identity(user)
    user.associate_with_identity(pending_identity) if pending_identity
    session.delete(:pending_identity_id)
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
    session.delete(:pending_membership_token)
  end

  def consume_pending_discussion_reader(user)
    if pending_discussion_reader
      DiscussionReaderSerivce.redeem(discussion_reader: pending_discussion_reader, actor: user)
    end
    session.delete(:pending_discussion_reader_token)
  end

  def consume_pending_stance(user)
    if pending_stance
      StanceService.redeem(stance: pending_stance, actor: user)
    end
    session.delete(:pending_stance_token)
  end

  def pending_group
    Group.find_by(token: session[:pending_group_token]) if session[:pending_group_token]
  end

  def pending_login_token
    LoginToken.find_by(token: session[:pending_login_token]) if session[:pending_login_token]
  end

  def pending_membership_token
    params[:membership_token] || session[:pending_membership_token]
  end

  def pending_membership
    Membership.formal.pending.find_by(token: pending_membership_token) if pending_membership_token
  end

  def pending_discussion_reader_token
    params[:discussion_reader_token] || session[:pending_discussion_reader_token]
  end

  def pending_discussion_reader
    DiscussionReader.redeemable.find_by(token: pending_discussion_reader_token)
  end

  def pending_stance_token
    params[:stance_token] || session[:pending_stance_token]
  end

  def pending_stance
    Stance.redeemable.find_by(token: pending_stance_token)
  end

  # def pending_guest_membership
  #   Membership.guest.pending.find_by(token: pending_membership_token) if pending_membership_token
  # end

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
    Pending::StanceSerializer.new(pending_stance, root: false).as_json ||
    Pending::DiscussionReaderSerializer.new(pending_discussion_reader, root: false).as_json ||
    Pending::GroupSerializer.new(pending_group, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json || {}
  end
end
