class Queries::VisibleMembers < Delegator

  def initialize(group: group, limit: limit)
    @relation = Membership.where(group: group)
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
