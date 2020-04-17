module PendingActionsHelper
  private
  def handle_pending_actions(user = current_user)
    if user.is_logged_in?
      session.delete(:pending_user_id) if pending_user
      consume_pending_login_token
      consume_pending_identity(user)
      consume_pending_group(user)
      consume_pending_membership(user)
      consume_pending_discussion_reader(user)
      consume_pending_stance(user)
      session.delete(:pending_login_token)
      session.delete(:pending_identity_id)
      session.delete(:pending_group_token)
      session.delete(:pending_discussion_reader_token)
      session.delete(:pending_stance_token)
    end
  end

  def consume_pending_login_token
    pending_login_token.update(used: true) if pending_login_token
  end

  def consume_pending_identity(user)
    user.associate_with_identity(pending_identity) if pending_identity
  end

  def consume_pending_group(user)
    if pending_group
      membership = pending_group.memberships.build(user: user)
      MembershipService.redeem(membership: membership, actor: user)
    end
  end

  def consume_pending_membership(user)
    if pending_membership
      MembershipService.redeem(membership: pending_membership, actor: user)
    end

    if pending_guest_model
      pending_guest_model.add_guest!(user, pending_membership.inviter)
    end
  end

  # memberships are valid even if not accepted, but this lets us know if people are using them
  def accept_pending_membership
    group = @group or (@discussion && @discussion.group)
    return unless group
    MembershipService.redeem_if_pending!(group.membership_for(current_user))
  end

  def consume_pending_discussion_reader(user)
    if pending_discussion_reader
      DiscussionReaderService.redeem(discussion_reader: pending_discussion_reader, actor: user)
    end
  end

  def consume_pending_stance(user)
    StanceService.redeem(stance: pending_stance, actor: user) if pending_stance
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
    Membership.pending.find_by(token: pending_membership_token) if pending_membership_token
  end

  def pending_guest_model
    if pending_membership_token && membership = Membership.find_by(token: pending_membership_token)
      Discussion.find_by(guest_group_id: membership.group_id) || Poll.find_by(guest_group_id: membership.group_id)
    else
      nil
    end
  end

  def pending_discussion_reader_token
    params[:discussion_reader_token] || session[:pending_discussion_reader_token]
  end

  def pending_discussion_reader
    DiscussionReader.redeemable.find_by(token: pending_discussion_reader_token) if pending_discussion_reader_token
  end

  def pending_stance_token
    params[:stance_token] || session[:pending_stance_token]
  end

  def pending_stance
    Stance.redeemable.find_by(token: pending_stance_token) if pending_stance_token
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
    Pending::StanceSerializer.new(pending_stance, root: false).as_json ||
    Pending::DiscussionReaderSerializer.new(pending_discussion_reader, root: false).as_json ||
    Pending::GroupSerializer.new(pending_group, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json || {}
  end
end
