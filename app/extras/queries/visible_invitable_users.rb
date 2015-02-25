class Queries::VisibleInvitableUsers < Delegator

  def initialize(user: nil, group: nil, query: nil, limit: nil)
    @user, @group, @query, @limit = user, group, query, limit
    @relation = visible_users_filtered
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  private

  def visible_users_filtered
    User.where(id: visible_member_ids)
        .where("name ilike #{search_term} or username ilike #{search_term}")
        .limit(@limit)
  end

  def visible_member_ids
    @visible_member_ids ||= @user.groups.flat_map { |g| g.member_ids }
                                        .reject   { |id| group_member_ids.include? id }
                                        .uniq
  end

  def group_member_ids
    @group_member_ids ||= @group.member_ids
  end

  def search_term
    @search_term ||= "'%#{@query}%'"
  end

end
