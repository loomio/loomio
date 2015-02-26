class SearchAlgorithms

  def self.sync
    "INSERT INTO discussion_search_vectors (discussion_id, search_vector)
     SELECT      id, #{discussion_vector}
     FROM        discussions
     LEFT JOIN (
       SELECT string_agg(name, ',')        AS active_motion_names,
              LEFT(string_agg(description, ','), 10000) AS active_motion_descriptions
       FROM   motions
       WHERE  discussion_id = :id
       AND    motions.closed_at IS NULL) active ON :id = id
     LEFT JOIN (
       SELECT string_agg(name, ',')        AS closed_motion_names,
              LEFT(string_agg(description, ','), 10000) AS closed_motion_descriptions
       FROM   motions
       WHERE  discussion_id = :id
       AND    motions.closed_at IS NOT NULL) closed ON :id = id
     LEFT JOIN (
       SELECT LEFT(string_agg(body, ','), 200000) AS comment_bodies
       FROM   comments
       WHERE  discussion_id = :id) comments ON :id = id
     WHERE    id = :id"
  end

  def self.search(visible_ids = [])
    "SELECT id,
            rank,
            ts_headline(discussions.description, plainto_tsquery(:query)) as blurb,
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
     ORDER BY   rank, created_at DESC"
  end

  def self.relevant_motions
    "SELECT   id, name, ts_headline(description, plainto_tsquery(:query)) as blurb
     FROM     motions
     WHERE    motions.discussion_id = :id
     AND      #{motion_vector} @@ plainto_tsquery(:query)
     ORDER BY created_at DESC
     LIMIT    :limit"
  end

  def self.relevant_comments
    "SELECT   id, ts_headline(body, plainto_tsquery(:query)) as blurb
     FROM     comments
     WHERE    comments.discussion_id = :id
     AND      #{comment_vector} @@ plainto_tsquery(:query)
     ORDER BY created_at DESC
     LIMIT    :limit"
  end

  private

  def self.discussion_vector
    [
      SearchVectorWeight.new('discussions.title',          :A),
      SearchVectorWeight.new('active_motion_names',        :B),
      SearchVectorWeight.new('discussions.description',    :C),
      SearchVectorWeight.new('closed_motion_names',        :C),
      SearchVectorWeight.new('active_motion_descriptions', :C),
      SearchVectorWeight.new('closed_motion_descriptions', :D),
      SearchVectorWeight.new('comment_bodies',             :D)
    ].map(&:to_s).join ' || '
  end

  def self.motion_vector
    [
      SearchVectorWeight.new('name',        :B),
      SearchVectorWeight.new('description', :C)
    ].map(&:to_s).join ' || '
  end

  def self.comment_vector
    [
      SearchVectorWeight.new('body', :D)
    ].map(&:to_s).join ' || '
  end

end
