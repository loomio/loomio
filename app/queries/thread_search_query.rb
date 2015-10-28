class ThreadSearchQuery

  WEIGHT_VALUES = [
    0.03, # D
    0.1,  # C
    0.3,  # B
    1.0   # A
  ]

  def initialize(query, user: nil, offset: 0, limit: 5, since: nil, till: nil)
    @query, @user, @offset, @limit, @since, @until  = query, user, offset, limit, since, till
  end

  def search_results
    return [] if visible_results.empty?
    @search_results ||= top_results.map { |result| build_search_result result }
  end

  private

  def model_cache
    @model_cache ||= ModelCache.new discussions: top_results,
                                    motions:     relevant_records_for(:motions),
                                    comments:    relevant_records_for(:comments)
  end

  def build_search_result(result)
    discussion_id = result['id']
    SearchResult.new model_cache.discussion_for(discussion_id),
                     model_cache.motion_for(discussion_id),
                     model_cache.comment_for(discussion_id),
                     model_cache.discussion_blurb_for(discussion_id),
                     model_cache.motion_blurb_for(discussion_id),
                     model_cache.comment_blurb_for(discussion_id),
                     result['query'],
                     result['rank']
  end

  def top_results
    @top_results ||= SearchVector.execute_search_query self.class.search_sql(visible_results), query: @query, offset: @offset, limit: @limit
  end

  def visible_results
    @visible_results ||= Queries::VisibleDiscussions.new(user: @user, groups: @user.groups).pluck(:id)
  end

  def relevant_records_for(model)
    return [] unless Rails.application.secrets.advanced_search_enabled
    SearchVector.execute_search_query self.class.send(:"relevant_#{model}_sql", top_results.map { |d| d['id'] }), query: @query
  end

  def self.index_thread_sql
    "INSERT INTO discussion_search_vectors (discussion_id, search_vector)
     SELECT      id, #{field_weights_sql(discussion_field_weights)}
     FROM        discussions
     LEFT JOIN (
       SELECT string_agg(name, ',')                     AS motion_names,
              LEFT(string_agg(description, ','), 10000) AS motion_descriptions
       FROM   motions
       WHERE  discussion_id = :id) motions ON :id = id
     LEFT JOIN (
       SELECT LEFT(string_agg(body, ','), 200000)       AS comment_bodies
       FROM   comments
       WHERE  discussion_id = :id) comments ON :id = id
     WHERE    id = :id"
  end

  def self.search_sql(visible_ids)
    "SELECT id,
            rank,
            :query as query,
            #{field_as_blurb_sql('discussions.description')} as blurb
     FROM (
        SELECT   discussion_id, search_vector, #{rank_sql} as rank
        FROM     discussion_search_vectors
        WHERE    search_vector @@ plainto_tsquery(:query)
        AND      discussion_id IN (#{visible_ids.join(',')})
        ORDER BY rank DESC
        OFFSET   :offset
        LIMIT    :limit
     ) vectors
     INNER JOIN discussions ON discussions.id = vectors.discussion_id
     WHERE      rank > 0
     ORDER BY   rank DESC, last_activity_at DESC"
  end

  def self.relevant_motions_sql(top_ids)
    "SELECT   DISTINCT ON (discussion_id)
              id,
              discussion_id,
              name,
              #{rank_sql(motion_field_weights)} as rank,
              #{field_as_blurb_sql('description')} as blurb
     FROM     motions
     WHERE    motions.discussion_id IN (#{top_ids.join(',')})
     AND      #{field_weights_sql(motion_field_weights)} @@ plainto_tsquery(:query)
     ORDER BY discussion_id, rank DESC"
  end

  def self.relevant_comments_sql(top_ids)
    "SELECT   DISTINCT ON (discussion_id)
              id,
              discussion_id,
              user_id,
              #{rank_sql(comment_field_weights)} as rank,
              #{field_as_blurb_sql('body')} as blurb
     FROM     comments
     WHERE    comments.discussion_id IN (#{top_ids.join(',')})
     AND      #{field_weights_sql(comment_field_weights)} @@ plainto_tsquery(:query)
     ORDER BY discussion_id, rank DESC"
  end

  private

  def self.rank_sql(search_vector = nil, search_vector_column = 'search_vector')
    "ts_rank_cd('{#{WEIGHT_VALUES.join(',')}}', #{field_weights_sql(search_vector) || search_vector_column}, plainto_tsquery(:query))"
  end

  def self.field_as_blurb_sql(field)
    "ts_headline(#{field}, plainto_tsquery(:query), 'ShortWord=0')"
  end

  def self.field_weights_sql(vector)
    return unless vector
    vector.map { |field, weight| "setweight(to_tsvector(coalesce(#{field}, '')), '#{weight}')" }.join ' || '
  end

  def self.discussion_field_weights
    {
      'discussions.title'        => :A,
      'motion_names'             => :B,
      'discussions.description'  => :C,
      'motion_descriptions'      => :C,
      'comment_bodies'           => :D
   }
  end

  def self.motion_field_weights
    {'name'        => :B,
     'description' => :C}
  end

  def self.comment_field_weights
    {'body' => :D} # So happy :D
  end

end
