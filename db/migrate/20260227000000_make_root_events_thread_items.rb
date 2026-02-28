class MakeRootEventsThreadItems < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    # Step 1: Set topic_id on new_discussion events (they previously had no topic_id)
    execute <<~SQL
      UPDATE events
      SET topic_id = d.topic_id
      FROM discussions d
      WHERE events.kind = 'new_discussion'
        AND events.eventable_type = 'Discussion'
        AND events.eventable_id = d.id
        AND events.topic_id IS NULL
    SQL

    # Step 2: Give root events (new_discussion + standalone poll_created) sequence data
    execute <<~SQL
      UPDATE events
      SET sequence_id = 0, position = 0, depth = 0, position_key = '00000'
      WHERE topic_id IS NOT NULL
        AND parent_id IS NULL
        AND sequence_id IS NULL
    SQL

    # Step 3: Prepend "00000-" to all non-root position_keys
    execute <<~SQL
      UPDATE events
      SET position_key = '00000-' || position_key
      WHERE topic_id IS NOT NULL
        AND parent_id IS NOT NULL
        AND position_key IS NOT NULL
    SQL

    # Step 4: Rebuild descendant_count for root events using the new position_key scheme
    execute <<~SQL
      UPDATE events
      SET descendant_count = (
        SELECT count(descendants.id)
        FROM events descendants
        WHERE descendants.topic_id = events.topic_id
          AND descendants.id != events.id
          AND descendants.position_key LIKE events.position_key || '%'
      )
      WHERE topic_id IS NOT NULL
        AND parent_id IS NULL
        AND position_key = '00000'
    SQL

    # Step 5: Update topic items_count and ranges_string to include sequence_id 0
    execute <<~SQL
      UPDATE topics
      SET items_count = items_count + 1,
          ranges_string = CASE
            WHEN ranges_string IS NULL OR ranges_string = '' THEN '0-0'
            ELSE '0-0,' || ranges_string
          END
      WHERE id IN (
        SELECT DISTINCT topic_id FROM events
        WHERE parent_id IS NULL AND sequence_id = 0 AND topic_id IS NOT NULL
      )
    SQL
  end

  def down
    # Reverse Step 5: Remove sequence_id 0 from ranges and decrement items_count
    execute <<~SQL
      UPDATE topics
      SET items_count = GREATEST(items_count - 1, 0),
          ranges_string = CASE
            WHEN ranges_string = '0-0' THEN NULL
            WHEN ranges_string LIKE '0-0,%' THEN SUBSTRING(ranges_string FROM 5)
            ELSE ranges_string
          END
      WHERE id IN (
        SELECT DISTINCT topic_id FROM events
        WHERE parent_id IS NULL AND sequence_id = 0 AND topic_id IS NOT NULL
      )
    SQL

    # Reverse Step 3: Remove "00000-" prefix from non-root position_keys
    execute <<~SQL
      UPDATE events
      SET position_key = SUBSTRING(position_key FROM 7)
      WHERE topic_id IS NOT NULL
        AND parent_id IS NOT NULL
        AND position_key LIKE '00000-%'
    SQL

    # Reverse Step 2: Remove sequence data from root events
    execute <<~SQL
      UPDATE events
      SET sequence_id = NULL, position = NULL, depth = NULL, position_key = NULL
      WHERE topic_id IS NOT NULL
        AND parent_id IS NULL
        AND sequence_id = 0
    SQL

    # Reverse Step 1: Remove topic_id from new_discussion events
    execute <<~SQL
      UPDATE events
      SET topic_id = NULL
      WHERE kind = 'new_discussion'
        AND eventable_type = 'Discussion'
        AND topic_id IS NOT NULL
    SQL
  end
end
