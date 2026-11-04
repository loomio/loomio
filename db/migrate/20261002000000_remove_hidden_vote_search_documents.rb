class RemoveHiddenVoteSearchDocuments < ActiveRecord::Migration[8.1]
  def up
    # Clear existing search entries for hidden poll conversations. Normal poll
    # reindexing restores them after closing.
    execute <<~SQL
      DELETE FROM pg_search_documents
      WHERE (searchable_type = 'Comment' AND searchable_id IN (
        SELECT topic_items.itemable_id FROM topic_items
        INNER JOIN topic_items poll_items ON poll_items.topic_id = topic_items.topic_id
          AND topic_items.position_key LIKE poll_items.position_key || '-%'
        INNER JOIN polls ON poll_items.itemable_type = 'Poll' AND poll_items.itemable_id = polls.id
        WHERE topic_items.itemable_type = 'Comment' AND poll_items.kind = 'poll_created'
          AND polls.hide_results = 2 AND polls.closed_at IS NULL
      ))
         OR (searchable_type = 'Stance' AND poll_id IN (
           SELECT id FROM polls WHERE hide_results = 2 AND closed_at IS NULL
         ))
    SQL
  end

  def down
    # Search documents are derived and can be rebuilt from current visibility.
  end
end
