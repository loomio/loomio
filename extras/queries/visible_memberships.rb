class Queries::VisibleMemberships < Delegator

  def initialize(user: nil, group: nil, query: nil, limit: nil)
    @user, @group, @query, @limit = user, group, query, limit
    @relation = @group.memberships.joins(:user)
                      .where("users.name ilike #{search_term} or users.username ilike #{search_term}")
                      .limit(limit)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def search_term
    "'%#{@query}%'"
  end

end
