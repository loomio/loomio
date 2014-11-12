class Queries::VisibleAutocompletes < Delegator

  def initialize(query: query, group: group, limit: limit, current_user: current_user)
    @relation = Membership.joins(:user)
                          .where(group: group)
                          .where("users.id != ?", current_user.id)
                          .where("users.name ilike '%#{query}%'")
                          .limit(limit)
    super @relation
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

end
