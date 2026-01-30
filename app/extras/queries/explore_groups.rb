class Queries::ExploreGroups < Delegator
  def initialize
    @relation = Group.where(listed_in_explore: true)
                     .parents_only
                     .published
    @relation
  end

  def search_for(q)
    @relation = @relation.explore_search(q) if q.present?
    self
  end

  def __getobj__
    @relation
  end
end
