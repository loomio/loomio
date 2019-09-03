class GroupInviter
  class InvitationLimitExceededError < Exception; end

  def initialize(group:, inviter: User.helper_bot, user_ids: [], emails: [], invited_group_ids: [])
    @group    = group
    @inviter  = inviter
    @user_ids = Array(user_ids)
    @emails   = Array(emails)
    @invited_group_ids = Array(invited_group_ids)
  end

  def invite!
    raise InvitationLimitExceededError if rate_limit_exceeded?
    generate_users!
    generate_memberships!
    @group.target_model.update_undecided_count
    @group.update_pending_memberships_count
    @group.update_memberships_count
    self
  end

  def rate_limit_exceeded?
    @emails.length > @inviter.pending_invitation_limit
  end

  def invited_members
    @invited_members ||= User.where("id in (:ids) or email in (:emails)", ids: @user_ids, emails: @emails)
  end

  def invited_memberships
    @invited_memberships ||= @group.memberships.where(user: invited_members)
  end

  private

  def generate_users!
    User.import(@emails.uniq.map do |email|
      User.new(email: email, time_zone: @inviter.time_zone, detected_locale: @inviter.locale)
    end, on_duplicate_key_ignore: true)
  end

  def generate_memberships!
    # only generate memberships for people who are not in the formal group
    existing_member_ids = (@group.reload.all_member_ids + @group.target_model.group.all_member_ids).uniq
    memberships = invited_members.where.not(id: existing_member_ids).map { |user| membership_for(user) }
    Membership.import(memberships).ids
  end

  def membership_for(user)
    Membership.new(inviter: @inviter,
                   user: user,
                   group: @group,
                   volume: (2 if @group.is_formal_group?),
                   experiences: {invited_group_ids: @invited_group_ids}.compact )
  end
end
