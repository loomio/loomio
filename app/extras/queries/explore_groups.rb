class Queries::ExploreGroups < Delegator
  def initialize
    @relation = Group.where(is_visible_to_public: true).
                            parents_only.
                            created_earlier_than(2.months.ago).
                            active_discussions_since(1.month.ago).
                            more_than_n_members(3).
                            more_than_n_discussions(3).
                            order('discussions.last_comment_at')

  end

  def search_for(q)
    @relation = @relation.search_full_name(q) if q
    self
  end

  def __getobj__
    @relation
  end
end
