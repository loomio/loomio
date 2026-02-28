class SearchService
  BATCH_SIZE = 50_000

  def self.reindex_everything
    PgSearch::Document.delete_all
    reindex_in_batches("Discussion", Discussion)
    reindex_in_batches("Poll", Poll)
    reindex_in_batches("Comment", Comment)
    reindex_in_batches("Stance", Stance)
    reindex_in_batches("Outcome", Outcome)
  end

  private_class_method def self.reindex_in_batches(type, model)
    total = 0
    min_id = 0
    max = model.unscoped.maximum(:id).to_i
    count = model.respond_to?(:kept) ? model.kept.count : model.count
    puts "  #{type}: #{count} records to index (max id: #{max})"
    cursor = max
    while cursor > 0
      lower = [cursor - BATCH_SIZE, 0].max
      sql = model.pg_search_insert_statement + " AND #{model.table_name}.id > #{lower} AND #{model.table_name}.id <= #{cursor}"
      rows = ActiveRecord::Base.connection.execute(sql).cmd_tuples
      total += rows
      puts "  reindex_everything #{type}: #{total} rows inserted so far (id #{lower}..#{cursor})"
      cursor = lower
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