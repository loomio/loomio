class SearchVector::Motion < SearchVector::Base
  self.table_name = :motion_search_vectors
  belongs_to :motion

  def self.resource_class
    ::Motion
  end

  def self.searchable_fields
    [:name, :description]
  end

  def self.tsvector_algorithm
    "setweight(to_tsvector(:name),        'A') ||
     setweight(to_tsvector(:description), 'B')"
  end

  def self.ranking_algorithm
    "ts_rank_cd(search_vector, :query)"
  end

  def self.visible_results_for(user)
    Queries::VisibleMotions.new(user: user).pluck(:id)
  end
end
