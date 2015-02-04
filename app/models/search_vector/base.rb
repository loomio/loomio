class SearchVector::Base < ActiveRecord::Base
  self.abstract_class = true

  def self.search_for(query, user: nil, limit: 5)
    connection.execute(sanitize_sql_array [
      "SELECT     id, #{ranking_algorithm} as rank, :query as query
       FROM (
          SELECT  #{resource_class_id}, search_vector
          FROM    #{table_name}
          WHERE   search_vector @@ to_tsquery(:query)
       ) vectors
       INNER JOIN #{model_table_name} model ON model.id = vectors.#{resource_class_id}
       AND        model.#{visibility_column} IN (#{visible_results_for(user).join(',')})
       ORDER BY   rank, created_at DESC
       LIMIT      :limit", query: query, limit: limit
    ]).map { |result| build_search_result result }
  end

  def self.build_search_result(result)
    SearchResult.new resource_class.find(result['id']), result['query'], result['rank']
  end

  def self.sync_searchable!(searchable)
    connection.execute sanitize_sql_array [
      search_vector_sync_query(searchable),
      search_vector_sync_options(searchable)
    ]
  end

  def self.search_vector_sync_query(searchable)
    if searchable.reload.search_vector.blank?
      "INSERT INTO #{table_name} (#{resource_class_id}, search_vector)
       SELECT      id, #{tsvector_algorithm}
       FROM        #{resource_class.to_s.pluralize.downcase} as model
       WHERE       model.id = :id"
    else
      "UPDATE      #{table_name}
       SET         search_vector = #{tsvector_algorithm}
       WHERE       #{resource_class_id} = :id"
    end
  end

  def self.search_vector_sync_options(searchable)
    { id: searchable.id }.tap do |hash|
      searchable_fields.each { |field| hash[field] = searchable.send(field) }
    end
  end

  def self.resource_class_id
    "#{resource_class}_id".downcase
  end

  def self.model_table_name
    resource_class.to_s.downcase.pluralize
  end

  def self.resource_class
    raise NotImplementedError.new
  end

  def self.searchable_fields
    raise NotImplementedError.new
  end

  def self.tsvector_algorithm
    raise NotImplementedError.new
  end

  def self.ranking_algorithm
    raise NotImplementedError.new
  end

  def self.visible_results_for(user)
    Queries::VisibleDiscussions.new(user: user).pluck(:id)
  end

  def self.visibility_column
    :id
  end

end
