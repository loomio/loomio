class SearchService
  def self.reindex_everything
    PgSearch::Document.delete_all
    [
      Discussion.pg_search_insert_statement,
      Comment.pg_search_insert_statement,
      Poll.pg_search_insert_statement,
      Stance.pg_search_insert_statement,
      Outcome.pg_search_insert_statement
    ].each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def self.reindex_by_author_id(author_id)
    PgSearch::Document.where(author_id: author_id).delete_all

    [
      Discussion.pg_search_insert_statement(author_id: author_id),
      Comment.pg_search_insert_statement(author_id: author_id),
      Poll.pg_search_insert_statement(author_id: author_id),
      Stance.pg_search_insert_statement(author_id: author_id),
      Outcome.pg_search_insert_statement(author_id: author_id),
    ].each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def self.reindex_by_discussion_id(discussion_id)
    PgSearch::Document.where(discussion_id: discussion_id).delete_all

    topic_id = Topic.where(topicable_type: 'Discussion', topicable_id: discussion_id).pick(:id)

    statements = [
      Discussion.pg_search_insert_statement(id: discussion_id),
      (Comment.pg_search_insert_statement(topic_id: topic_id) if topic_id),
    ]

    if topic_id
      Poll.where(topic_id: topic_id).pluck(:id).each do |poll_id|
        statements << Poll.pg_search_insert_statement(id: poll_id)
        statements << Stance.pg_search_insert_statement(poll_id: poll_id)
        statements << Outcome.pg_search_insert_statement(poll_id: poll_id)
      end
    end

    statements.compact.each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def self.reindex_by_poll_id(poll_id)
    PgSearch::Document.where(poll_id: poll_id).delete_all

    [
      Poll.pg_search_insert_statement(id: poll_id),
      Stance.pg_search_insert_statement(poll_id: poll_id),
      Outcome.pg_search_insert_statement(poll_id: poll_id),
    ].each do |statement|
      ActiveRecord::Base.connection.execute(statement)
    end
  end

  def self.reindex_by_comment_id(comment_id)
    # Comment.find(comment_id).update_pg_search_document
    PgSearch::Document.where(searchable_type: 'Comment', searchable_id: comment_id).delete_all
    ActiveRecord::Base.connection.execute(Comment.pg_search_insert_statement(id: comment_id))
  end

end