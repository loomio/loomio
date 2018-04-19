class GroupInviter
  class NoInvitationsAvailableError < Exception; end
  class InvitationLimitExceededError < Exception; end

  def initialize(group:, inviter: User.helper_bot, user_ids: [], emails: [])
    @group    = group
    @inviter  = inviter
    @user_ids = Array(user_ids)
    @emails   = Array(emails)
  end

  def invite!
    generate_users!
    generate_memberships!
    @group.update_pending_memberships_count
    @group.update_memberships_count
    raise NoInvitationsAvailableError  if invited_members.count == 0
    raise InvitationLimitExceededError if invitation_limit_exceeded?
    self
  end

  def invited_members
    @invited_members ||= User.where(id: [@user_ids, @generated_user_ids].flatten.compact)
  end

  def invited_memberships
    @invited_memberships ||= @group.memberships.where(user: invited_members)
  end

  private

  def invitation_limit_exceeded?
    @group.members.unverified.count > @group.pending_invitation_limit
  end

  def generate_users!
    @generated_user_ids ||= User.import(@emails.uniq.map { |email| User.new(email: email) }).ids
  end

  def generate_memberships!
    @generated_membership_ids ||= begin
      memberships = invited_members.where.not(id: @group.member_ids).map { |user| membership_for(user) }
      Membership.import(memberships).ids
    end
  end

  def membership_for(user)
    Membership.new(inviter: @inviter,
                   user: user,
                   group: @group,
                   volume: Membership.volumes[:normal],
                   accepted_at: (Time.now if user.email_verified))
  end
end
