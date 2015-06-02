class Queries::VisibleAutocompletes < Delegator

  def initialize(query: , group: , limit: , current_user: )
    @relation = Membership.active.joins(:user)
                          .where(group: group)
                          .where("users.id != ?", current_user.id)
                          .where("users.name ilike :q OR
                                  users.username ilike :q", q: "#{query}%")
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
