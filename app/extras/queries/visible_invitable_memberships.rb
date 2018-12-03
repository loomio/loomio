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
    Membership.select("DISTINCT ON (user_id) memberships.*")
              .where(user_id: visible_user_ids, group_id: @user.group_ids, archived_at: nil)
              .search_for(@query)
              .limit(@limit)
  end

  def visible_user_ids
    Membership.connection.execute(
      "SELECT DISTINCT memberships.user_id
       FROM memberships
       LEFT OUTER JOIN users u ON u.id = memberships.user_id AND memberships.group_id = #{@group.id}
       WHERE memberships.group_id IN (#{@user.group_ids.join(', ')})
       AND   u.id IS NULL
       AND   u.deactivated_at IS NULL").values.flatten.map(&:to_i)
  end

  def group_membership_ids
    @group_membership_ids ||= @group.membership_ids
  end

  def search_term
    @search_term ||= "'%#{@query}%'"
  end

end
