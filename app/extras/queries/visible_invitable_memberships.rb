class Queries::VisibleInvitableMemberships < Delegator

  def initialize(user: nil, group: nil, query: nil, limit: nil)
    @user, @group, @query, @limit = user, group, query, limit
    @relation = visible_memberships_filtered
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  private

  def visible_memberships_filtered
    Membership.where(id: visible_membership_ids)
              .search_for(@query)
              .limit(@limit)
  end

  def visible_membership_ids
    @visible_member_ids ||= @user.groups.flat_map { |g| g.membership_ids }
                                        .reject   { |id| group_membership_ids.include? id }
                                        .uniq
  end

  def group_membership_ids
    @group_membership_ids ||= @group.membership_ids
  end

  def search_term
    @search_term ||= "'%#{@query}%'"
  end

end
