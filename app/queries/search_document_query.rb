class SearchDocumentQuery
  # Indexing is asynchronous. Check the live source before returning indexed
  # text, including after deletion, redaction, a move, or a result-setting change.
  # Correlated primary-key lookups keep this work local to matching documents.
  def self.current(relation)
    documents = PgSearch::Document.arel_table
    comment_items = TopicItem.tags_visible.where(kind: 'new_comment', itemable_type: 'Comment')
      .where(TopicItem.arel_table[:itemable_id].eq(documents[:searchable_id]))
      .where(TopicItem.arel_table[:topic_id].eq(documents[:topic_id]))
      .select(:id).limit(1).offset(0)

    relation.where(<<~SQL.squish)
      CASE pg_search_documents.searchable_type
      WHEN 'Discussion' THEN EXISTS (
        SELECT 1 FROM discussions
        WHERE discussions.id = pg_search_documents.searchable_id
          AND discussions.topic_id = pg_search_documents.topic_id
          AND discussions.discarded_at IS NULL LIMIT 1 OFFSET 0
      )
      WHEN 'Comment' THEN EXISTS (#{comment_items.to_sql})
      WHEN 'Poll' THEN EXISTS (
        SELECT 1 FROM polls
        WHERE polls.id = pg_search_documents.searchable_id
          AND polls.topic_id = pg_search_documents.topic_id
          AND polls.discarded_at IS NULL LIMIT 1 OFFSET 0
      )
      WHEN 'Stance' THEN EXISTS (
        SELECT 1 FROM stances JOIN polls ON polls.id = stances.poll_id
        WHERE stances.id = pg_search_documents.searchable_id
          AND polls.topic_id = pg_search_documents.topic_id
          AND polls.discarded_at IS NULL AND NOT polls.anonymous
          AND NOT (polls.hide_results = 2 AND polls.closed_at IS NULL)
          AND stances.cast_at IS NOT NULL AND stances.redacted_at IS NULL LIMIT 1 OFFSET 0
      )
      WHEN 'Outcome' THEN EXISTS (
        SELECT 1 FROM outcomes JOIN polls ON polls.id = outcomes.poll_id
        WHERE outcomes.id = pg_search_documents.searchable_id
          AND polls.topic_id = pg_search_documents.topic_id
          AND polls.discarded_at IS NULL LIMIT 1 OFFSET 0
      )
      ELSE FALSE END
    SQL
  end
end
