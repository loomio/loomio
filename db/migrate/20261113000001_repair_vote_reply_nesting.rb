class RepairVoteReplyNesting < ActiveRecord::Migration[8.1]
  # Select the sparse set of misplaced replies once, then let the existing
  # repair worker rebuild each topic under its normal write lock. The delay
  # leaves the deployment window for web and worker processes to upgrade.
  def up
    topic_ids = connection.transaction do
      connection.execute("SET LOCAL lock_timeout = '1s'")
      connection.execute("SET LOCAL statement_timeout = '15s'")
      affected_topic_ids
    end
    say "Found #{topic_ids.size} topics with misplaced vote replies"
    topic_ids.each do |topic_id|
      RepairTopicWorker.set(wait: 10.minutes, queue: :low).perform_later(topic_id)
    end
    topic_ids
  end

  def down
    # Corrected timeline ancestry is derived data and needs no reversal.
  end

  private

  # The comment's domain parent still identifies the vote. Its first timeline
  # item must be stance_updated, and the stored display parent must differ from
  # the expected parent after applying the thread's nesting limit.
  def affected_topic_ids
    connection.select_values(<<~SQL).map(&:to_i)
      SELECT replies.topic_id
      FROM topic_items replies
      INNER JOIN comments ON comments.id = replies.itemable_id AND comments.parent_type = 'Stance'
      INNER JOIN stances votes ON votes.id = comments.parent_id
      INNER JOIN polls ON polls.id = votes.poll_id AND polls.topic_id = replies.topic_id
      INNER JOIN topics ON topics.id = replies.topic_id
      INNER JOIN LATERAL (
        SELECT id, kind, parent_id, depth FROM topic_items vote_items
        WHERE vote_items.itemable_type = 'Stance' AND vote_items.itemable_id = votes.id
          AND vote_items.topic_id = replies.topic_id
          AND vote_items.kind IN ('stance_created', 'stance_updated')
        ORDER BY id LIMIT 1
      ) vote_item ON vote_item.kind = 'stance_updated'
      WHERE replies.kind = 'new_comment' AND replies.itemable_type = 'Comment'
        AND replies.parent_id IS DISTINCT FROM
          CASE WHEN topics.max_depth = vote_item.depth THEN vote_item.parent_id ELSE vote_item.id END
      GROUP BY replies.topic_id
      ORDER BY MAX(replies.id) DESC
    SQL
  end
end
