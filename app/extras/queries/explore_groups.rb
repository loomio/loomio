class Queries::ExploreGroups < Delegator
  def initialize
    min_members = ENV.fetch('EXPLORE_MIN_MEMBERS', 0)
    min_threads = ENV.fetch('EXPLORE_MIN_THREADS', 0)
    require_subscription = ENV.fetch('EXPLORE_REQUIRE_SUBSCRIPTION', false)

    @relation = FormalGroup.where(is_visible_to_public: true)
                     .parents_only
                     .published
                     .where('groups.name IS NOT NULL')
                     .where('groups.memberships_count > ?', min_members)
                     .where('groups.discussions_count > ?', min_threads)

    if require_subscription
      @relation = @relation.eager_load(:subscription)
                           .where("subscriptions.state = 'active'")
    end

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
