class SearchService
  BATCH_SIZE = 50_000
  SEARCHABLE_TYPES = %w[Comment Discussion Outcome Poll Stance].freeze

  # Serialize document replacements, including overlapping bulk jobs, without
  # locking source records that web requests need. A failed insert restores the
  # previous index rows; retries always query the latest committed source data.
  def self.with_index_lock(*types)
    PgSearch::Document.transaction(requires_new: true) do
      connection = PgSearch::Document.connection
      types.sort.each do |type|
        connection.execute("SELECT pg_advisory_xact_lock(hashtext('loomio_search_index'), hashtext(#{connection.quote(type)}))")
      end
      yield
    end
  end

  def self.reindex_record(model, id)
    with_index_lock(model.name) do
      PgSearch::Document.where(searchable_type: model.name, searchable_id: id).delete_all
      model.connection.execute(model.pg_search_insert_statement(id: id))
    end
  end

  def self.reindex_everything
    with_index_lock(*SEARCHABLE_TYPES) { PgSearch::Document.delete_all }
    reindex_in_batches("Discussion", Discussion)
    reindex_in_batches("Poll", Poll)
    reindex_in_batches("Comment", Comment)
    reindex_in_batches("Stance", Stance)
    reindex_in_batches("Outcome", Outcome)
    rebuild_words
  end

  def self.rebuild_words
    connection = ActiveRecord::Base.connection
    connection.execute("SELECT pg_advisory_lock(hashtext('loomio_rebuild_search_words'))")

    connection.execute("DROP TABLE IF EXISTS pg_search_words_rebuild")
    connection.execute <<~SQL
      CREATE TABLE pg_search_words_rebuild (
        word text NOT NULL,
        document_count integer NOT NULL
      )
    SQL
    connection.execute <<~SQL
        INSERT INTO pg_search_words_rebuild (word, document_count)
        SELECT word, ndoc
        FROM ts_stat('SELECT ts_content FROM pg_search_documents')
        WHERE ndoc >= 3
          AND length(word) BETWEEN 4 AND 64
          AND word ~ '^[[:alpha:]][[:alpha:]''’_-]{3,63}$'
    SQL
    connection.execute <<~SQL
      CREATE UNIQUE INDEX index_pg_search_words_rebuild_on_word
        ON pg_search_words_rebuild (word)
    SQL
    connection.execute <<~SQL
      CREATE INDEX index_pg_search_words_rebuild_on_word_trigram
        ON pg_search_words_rebuild USING gin (word gin_trgm_ops)
    SQL
    connection.execute("ANALYZE pg_search_words_rebuild")

    ActiveRecord::Base.transaction do
      connection.execute("ALTER TABLE pg_search_words RENAME TO pg_search_words_previous")
      connection.execute("ALTER TABLE pg_search_words_rebuild RENAME TO pg_search_words")
      connection.execute("DROP TABLE pg_search_words_previous")
      connection.execute <<~SQL
        ALTER INDEX index_pg_search_words_rebuild_on_word
          RENAME TO index_pg_search_words_on_word
      SQL
      connection.execute <<~SQL
        ALTER INDEX index_pg_search_words_rebuild_on_word_trigram
          RENAME TO index_pg_search_words_on_word_trigram
      SQL
    end
  ensure
    connection&.execute("SELECT pg_advisory_unlock(hashtext('loomio_rebuild_search_words'))")
  end

  private_class_method def self.reindex_in_batches(type, model)
    total = 0
    min_id = 0
    max = model.unscoped.maximum(:id).to_i
    count = model.respond_to?(:kept) ? model.kept.count : model.count
    # puts "  #{type}: #{count} records to index (max id: #{max})"
    cursor = max
    while cursor > 0
      lower = [ cursor - BATCH_SIZE, 0 ].max
      sql = model.pg_search_insert_statement + " AND #{model.table_name}.id > #{lower} AND #{model.table_name}.id <= #{cursor}"
      rows = with_index_lock(type) do
        PgSearch::Document.where(searchable_type: type, searchable_id: (lower + 1)..cursor).delete_all
        ActiveRecord::Base.connection.execute(sql).cmd_tuples
      end
      total += rows
      # puts "  reindex_everything #{type}: #{total} rows inserted so far (id #{lower}..#{cursor})"
      cursor = lower
    end
  end

  def self.reindex_by_author_id(author_id)
    with_index_lock(*SEARCHABLE_TYPES) do
      PgSearch::Document.where(author_id: author_id).delete_all

      [
        Discussion.pg_search_insert_statement(author_id: author_id),
        Comment.pg_search_insert_statement(author_id: author_id),
        Poll.pg_search_insert_statement(author_id: author_id),
        Stance.pg_search_insert_statement(author_id: author_id),
        Outcome.pg_search_insert_statement(author_id: author_id)
      ].each do |statement|
        ActiveRecord::Base.connection.execute(statement)
      end
    end
  end

  def self.reindex_by_discussion_id(discussion_id)
    with_index_lock(*SEARCHABLE_TYPES) do
      PgSearch::Document.where(discussion_id: discussion_id).delete_all

      topic = Topic.find_by(topicable_type: 'Discussion', topicable_id: discussion_id)
      return if topic.nil? || topic.discarded_at.present? || topic.topicable.discarded_at.present?

      topic_id = topic.id

      statements = [
        Discussion.pg_search_insert_statement(id: discussion_id),
        (Comment.pg_search_insert_statement(topic_id: topic_id) if topic_id)
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
  end

  def self.reindex_by_poll_id(poll_id)
    with_index_lock('Comment', 'Outcome', 'Poll', 'Stance') do
      comment_ids = Comment.under_polls(Poll.where(id: poll_id)).select(:id)
      PgSearch::Document.where(searchable_type: 'Comment', searchable_id: comment_ids).delete_all
      PgSearch::Document.where(poll_id: poll_id).delete_all

      [
        Poll.pg_search_insert_statement(id: poll_id),
        Stance.pg_search_insert_statement(poll_id: poll_id),
        Outcome.pg_search_insert_statement(poll_id: poll_id),
        Comment.pg_search_insert_statement(poll_id: poll_id)
      ].each do |statement|
        ActiveRecord::Base.connection.execute(statement)
      end
    end
  end

  def self.reindex_by_comment_id(comment_id)
    reindex_record(Comment, comment_id)
  end
end
