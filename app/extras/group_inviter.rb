class GroupInviter
  class InvitationLimitExceededError < Exception; end

  def initialize(group:, inviter: User.helper_bot, user_ids: [], emails: [])
    @group    = group
    @inviter  = inviter
    @user_ids = Array(user_ids)
    @emails   = Array(emails)
  end

  def invite!
    raise InvitationLimitExceededError if rate_limit_exceeded?
    generate_users!
    generate_memberships!
    @group.update_pending_memberships_count
    @group.update_memberships_count
    self
  end

  def rate_limit_exceeded?
    @emails.length > @inviter.pending_invitation_limit
  end

  def invited_members
    @invited_members ||= User.where(id: [@user_ids, @generated_user_ids].flatten.compact)
  end

  def invited_memberships
    @invited_memberships ||= @group.memberships.where(user: invited_members)
  end

  private

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
