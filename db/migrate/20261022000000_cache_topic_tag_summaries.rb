class CacheTopicTagSummaries < ActiveRecord::Migration[8.1]
  def up
    add_column :topics, :has_tagged_replies, :boolean, default: false, null: false

    # Backfill derived thread fields without application callbacks or jobs.
    # Existing assignments remain public metadata when poll results are hidden.
    execute <<~SQL
      WITH RECURSIVE discarded_poll_comments AS (
        SELECT id FROM comments
        WHERE (parent_type = 'Poll' AND parent_id IN (SELECT id FROM polls WHERE discarded_at IS NOT NULL))
          OR (parent_type = 'Stance' AND parent_id IN (
            SELECT stances.id FROM stances JOIN polls ON polls.id = stances.poll_id WHERE polls.discarded_at IS NOT NULL
          ))
          OR (parent_type = 'Outcome' AND parent_id IN (
            SELECT outcomes.id FROM outcomes JOIN polls ON polls.id = outcomes.poll_id WHERE polls.discarded_at IS NOT NULL
          ))
        UNION
        SELECT comments.id FROM comments JOIN discarded_poll_comments
          ON comments.parent_type = 'Comment' AND comments.parent_id = discarded_poll_comments.id
      ), summaries AS (
        SELECT items.topic_id, array_agg(DISTINCT names.name) AS tags,
          bool_or(items.sequence_id > 0) AS has_tagged_replies
        FROM topic_items items
        CROSS JOIN LATERAL unnest(items.tags) names(name)
        WHERE
          (items.itemable_type = 'Discussion' AND items.itemable_id IN (SELECT id FROM discussions WHERE discarded_at IS NULL)) OR
          (items.itemable_type = 'Poll' AND items.itemable_id IN (SELECT id FROM polls WHERE discarded_at IS NULL)) OR
          (items.itemable_type = 'Outcome' AND items.itemable_id IN (
            SELECT outcomes.id FROM outcomes JOIN polls ON polls.id = outcomes.poll_id WHERE polls.discarded_at IS NULL
          )) OR
          (items.itemable_type = 'Comment' AND items.itemable_id IN (SELECT id FROM comments WHERE discarded_at IS NULL)
            AND items.itemable_id NOT IN (SELECT id FROM discarded_poll_comments))
        GROUP BY items.topic_id
      ), projected AS (
        SELECT topics.id,
          ARRAY(SELECT name FROM unnest(summaries.tags) names(name) ORDER BY lower(name), name) AS tags,
          COALESCE(summaries.has_tagged_replies, FALSE) AS has_tagged_replies
        FROM topics LEFT JOIN summaries ON summaries.topic_id = topics.id
      )
      UPDATE topics SET tags = projected.tags,
        has_tagged_replies = projected.has_tagged_replies
      FROM projected WHERE topics.id = projected.id
    SQL
  end

  def down
    remove_column :topics, :has_tagged_replies
  end
end
