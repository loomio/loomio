class Queries::ExploreGroups < Delegator
  def initialize
    min_members = ENV.fetch('EXPLORE_MIN_MEMBERS', 4)
    min_threads = ENV.fetch('EXPLORE_MIN_THREADS', 2)
    @relation = FormalGroup.where(is_visible_to_public: true)
                     .parents_only
                     .published
                     .where('groups.name IS NOT NULL')
                     .where('groups.memberships_count > ?', min_members)
                     .where('groups.discussions_count > ?', min_threads)
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
