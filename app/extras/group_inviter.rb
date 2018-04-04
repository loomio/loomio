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
    verified = @group.members.group(:email_verified).count
    verified[false] >= (verified[true] + ENV.fetch('MAX_PENDING_INVITATIONS', 100).to_i)
  end

  def generate_users!
    @generated_user_ids ||= User.import(@emails.map { |email| User.new(email: email) }).ids
  end

  def generate_memberships!
    @generated_membership_ids ||= begin
      memberships = invited_members.where.not(id: @group.member_ids).map do |user|
        Membership.new(inviter: @inviter, user: user, group: @group)
      end
      Membership.import(memberships).ids
    end
  end
end
