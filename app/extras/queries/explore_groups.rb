class Queries::ExploreGroups < Delegator
  def initialize
    @relation = FormalGroup.where(is_visible_to_public: true)
                     .parents_only
                     .published
                     .where.not(name: nil)
                     .where('memberships_count > 4')
                     .where('discussions_count > 2')
                     .eager_load(:subscription)
                     .where("subscriptions.state = 'active'")
  end

  def search_for(q)
    @relation = @relation.explore_search(q) if q.present?
    self
  end

  def __getobj__
    @relation
  end
end
