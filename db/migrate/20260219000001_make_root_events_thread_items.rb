class MakeRootEventsThreadItems < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    # Step 1: Delete duplicate new_discussion events (keep the one with the lowest id)
    execute <<~SQL
      DELETE FROM events
      WHERE kind = 'new_discussion'
        AND eventable_type = 'Discussion'
        AND id NOT IN (
          SELECT MIN(id)
          FROM events
          WHERE kind = 'new_discussion' AND eventable_type = 'Discussion'
          GROUP BY eventable_id
        )
    SQL

    # Step 2: Set topic_id on new_discussion events (they previously had no topic_id)
    execute <<~SQL
      UPDATE events
      SET topic_id = d.topic_id
      FROM discussions d
      WHERE events.kind = 'new_discussion'
        AND events.eventable_type = 'Discussion'
        AND events.eventable_id = d.id
        AND events.topic_id IS NULL
    SQL

    # Step 3: Give root events (new_discussion + standalone poll_created) sequence data
    execute <<~SQL
      UPDATE events
      SET sequence_id = 0, position = 0, depth = 0, position_key = '00000'
      WHERE topic_id IS NOT NULL
        AND parent_id IS NULL
        AND sequence_id IS NULL
    SQL

    # Step 4: Prepend "00000-" to all non-root position_keys
    execute <<~SQL
      UPDATE events
      SET position_key = '00000-' || position_key
      WHERE topic_id IS NOT NULL
        AND parent_id IS NOT NULL
        AND position_key IS NOT NULL
    SQL

    # Step 5: Update topic items_count and ranges_string to include sequence_id 0.
    # If the topic already had a range starting at 1 (the common case), merge
    # it with 0 instead of leaving '0-0,1-N'.
    execute <<~SQL
      UPDATE topics
      SET items_count = items_count + 1,
          ranges_string = CASE
            WHEN ranges_string IS NULL OR ranges_string = '' THEN '0-0'
            WHEN ranges_string LIKE '1-%' THEN '0-' || SUBSTRING(ranges_string FROM 3)
            ELSE '0-0,' || ranges_string
          END
      WHERE id IN (
        SELECT DISTINCT topic_id FROM events
        WHERE parent_id IS NULL AND sequence_id = 0 AND topic_id IS NOT NULL
      )
    SQL

    # Step 6: Anyone who had read the topic before should also be considered
    # to have read the new root event. Add 0 to read_ranges_string for every
    # topic_reader with a last_read_at, using the same merge logic as Step 5.
    execute <<~SQL
      UPDATE topic_readers
      SET read_ranges_string = CASE
        WHEN read_ranges_string IS NULL OR read_ranges_string = '' THEN '0-0'
        WHEN read_ranges_string LIKE '1-%' THEN '0-' || SUBSTRING(read_ranges_string FROM 3)
        ELSE '0-0,' || read_ranges_string
      END
      WHERE last_read_at IS NOT NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
