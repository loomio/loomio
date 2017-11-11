class Queries::ExploreGroups < Delegator
  def initialize
    @relation = FormalGroup.where(is_visible_to_public: true)
                     .parents_only
                     .published
                     .order('(groups.recent_activity_count / groups.memberships_count) DESC')

  end

  def search_for(q)
    @relation = @relation.explore_search(q) if q.present?
    self
  end

  def __getobj__
    @relation
  end
end
