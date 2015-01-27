class SearchVector::Base < ActiveRecord::Base
  self.abstract_class = true

  def self.search_for(query, user: nil, limit: 5)
    connection.execute(sanitize_sql_array [
      "SELECT   #{resource_class_id}, #{ranking_algorithm} as rank
       FROM     #{table_name}
       WHERE    search_vector @@ to_tsquery(:query)
       AND      #{resource_class_id} IN (#{visible_results_for(user).join(',')})
       ORDER BY rank DESC
       LIMIT    :limit", query: query, limit: limit
    ]).map { |result| SearchResult.new resource_class.find(result[resource_class_id]), query, result['rank'] }
  end

  def self.sync_searchable!(searchable)
    connection.execute sanitize_sql_array [
      search_vector_sync_query(searchable),
      search_vector_sync_options(searchable)
    ]
  end

  def self.search_vector_sync_query(searchable)
    if searchable.reload.search_vector.blank?
      "INSERT INTO
        #{table_name} (#{resource_class_id}, search_vector)
      SELECT
        id, #{tsvector_algorithm}
      FROM
        #{resource_class.to_s.pluralize.downcase} as model
      WHERE
        model.id = :id"
    else
      "UPDATE
         #{table_name}
       SET
         search_vector = #{tsvector_algorithm}
       WHERE
         #{resource_class_id} = :id"
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

  def self.visible_results_for
    raise NotImplementedError.new
  end

end
