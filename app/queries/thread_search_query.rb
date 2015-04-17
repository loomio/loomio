class ThreadSearchQuery
  def self.search(query, user: nil, limit: 10)
    return [] if (visible_ids = visible_results_for(user)).empty?

    SearchVector.execute_search_query(
      search_sql(visible_ids),
      query: query,
      limit: limit
    ).map { |result| build_search_result result }
  end

  private

  def self.visible_results_for(user)
    Queries::VisibleDiscussions.new(user: user, groups: user.groups).pluck(:id)
  end

  def self.build_search_result(result)
    SearchResult.new(result['id'],
                     result['query'],
                     result['rank'],
                     result['blurb'],
                     relevant_motions(result['id'], result['query']),
                     relevant_comments(result['id'], result['query']))
  end

  def self.relevant_motions(discussion_id, query, limit: 1)
    SearchVector.execute_search_query(
      relevant_motions_sql,
      id: discussion_id,
      query: query,
      limit: limit
    ).map { |result| SearchResultChild.new :motion, result['id'], result['blurb'] }
  end

  def self.relevant_comments(discussion_id, query, limit: 1)
    SearchVector.execute_search_query(
      relevant_comments_sql,
      id:    discussion_id,
      query: query,
      limit: limit
    ).map { |result| SearchResultChild.new :comment, result['id'], result['blurb'] }
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

  def self.search_sql(visible_ids = [])
    "SELECT id,
            rank,
            #{field_as_blurb_sql('discussions.description')},
            :query as query
     FROM (
        SELECT   discussion_id, search_vector, ts_rank_cd(search_vector, plainto_tsquery(:query)) as rank
        FROM     discussion_search_vectors
        WHERE    search_vector @@ plainto_tsquery(:query)
        AND      discussion_id IN (#{visible_ids.join(',')})
        ORDER BY rank DESC
        LIMIT    :limit
     ) vectors
     INNER JOIN discussions ON discussions.id = vectors.discussion_id
     WHERE      rank > 0
     ORDER BY   rank DESC, last_activity_at DESC"
  end

  def self.relevant_motions_sql
    "SELECT   id,
              name,
              #{field_as_blurb_sql('description')}
     FROM     motions
     WHERE    motions.discussion_id = :id
     AND      #{field_weights_sql(motion_field_weights)} @@ plainto_tsquery(:query)
     ORDER BY created_at DESC
     LIMIT    :limit"
  end

  def self.relevant_comments_sql
    "SELECT   id,
              user_id,
              #{field_as_blurb_sql('body')}
     FROM     comments
     WHERE    comments.discussion_id = :id
     AND      #{field_weights_sql(comment_field_weights)} @@ plainto_tsquery(:query)
     ORDER BY created_at DESC
     LIMIT    :limit"
  end

  private
  def self.field_as_blurb_sql(field)
    "ts_headline(#{field}, plainto_tsquery(:query), 'ShortWord=0') as blurb"
  end

  def self.field_weights_sql(vector)
    vector.map do |field, weight|
      "setweight(to_tsvector(coalesce(#{field}, '')), '#{weight}')"
    end.join ' || '
  end

  def self.discussion_field_weights
    {'discussions.title'        => :A,
     'motion_names'             => :B,
     'discussions.description'  => :C,
     'motion_descriptions'      => :C,
     'comment_bodies'           => :D}
  end

  def self.motion_field_weights
    {'name'        => :B,
     'description' => :C}
  end

  def self.comment_field_weights
    {'body' => :D} # So happy :D
  end

end
