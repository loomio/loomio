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
    memberships = invited_members.where.not(id: @group.reload.all_member_ids).map { |user| membership_for(user) }
    Membership.import(memberships).ids
  end

  def membership_for(user)
    Membership.new(inviter: @inviter,
                   user: user,
                   group: @group,
                   volume: (2 if @group.is_formal_group?),
                   accepted_at: (Time.now if user.email_verified))
  end
end
