class BackfillDiscardedDiscussionTopics < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE topics
      SET discarded_at = discussions.discarded_at,
          discarded_by = discussions.discarded_by
      FROM discussions
      WHERE topics.topicable_type = 'Discussion'
        AND topics.topicable_id = discussions.id
        AND discussions.discarded_at IS NOT NULL
        AND topics.discarded_at IS NULL
    SQL

    execute <<~SQL
      DELETE FROM pg_search_documents
      USING discussions
      WHERE pg_search_documents.discussion_id = discussions.id
        AND discussions.discarded_at IS NOT NULL
    SQL
  end

  def down
  end
end
