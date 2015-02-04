class SearchVector::Discussion < SearchVector::Base
  self.table_name = :discussion_search_vectors
  belongs_to :discussion

  def self.resource_class
    ::Discussion
  end

  def self.searchable_fields
    [:title, :description]
  end

  def self.tsvector_algorithm
    "setweight(to_tsvector(:title),       'A') ||
     setweight(to_tsvector(:description), 'B')"
  end

  def self.ranking_algorithm
    "ts_rank_cd(search_vector, :query)"
  end

end
