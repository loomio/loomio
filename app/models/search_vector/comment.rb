class SearchVector::Comment < SearchVector::Base
  self.table_name = :comment_search_vectors
  belongs_to :comment

  def self.resource_class
    ::Comment
  end

  def self.searchable_fields
    [:body]
  end

  def self.tsvector_algorithm
    "setweight(to_tsvector(coalesce(:body,'')), 'A')"
  end

  def self.ranking_algorithm
    "ts_rank_cd(search_vector, :query)"
  end

  def self.visible_results_for(user)
    Queries::VisibleComments.new(user: user).pluck(:id)
  end
end
