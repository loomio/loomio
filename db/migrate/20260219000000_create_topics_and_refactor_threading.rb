class CreateTopicsAndRefactorThreading < ActiveRecord::Migration[7.0]
  def up
    # 1. Create topics table
    create_table :topics do |t|
      t.string  :topicable_type, null: false
      t.integer :topicable_id,   null: false
      t.integer :group_id
      t.integer :items_count,    default: 0, null: false
      t.string  :ranges_string
      t.integer :max_depth,      default: 2, null: false
      t.boolean :newest_first,   default: false, null: false
      t.boolean :private,        default: true, null: false
      t.datetime :closed_at, precision: nil
      t.integer :closer_id
      t.datetime :pinned_at, precision: nil
      t.datetime :last_activity_at, precision: nil
      t.integer :seen_by_count, default: 0, null: false
      t.integer :members_count
      t.integer :closed_polls_count, default: 0, null: false
      t.integer :anonymous_polls_count, default: 0, null: false
      t.timestamps
    end
    add_index :topics, [:topicable_type, :topicable_id], unique: true
    add_index :topics, :group_id

    # 2. Create topics from discussions using topic.id = discussion.id
    #    This means existing discussion_id columns already point to the right topic.
    execute <<~SQL
      INSERT INTO topics (id, topicable_type, topicable_id, group_id, items_count, ranges_string,
                          max_depth, newest_first, private, closed_at, closer_id, pinned_at,
                          last_activity_at, seen_by_count, members_count, closed_polls_count,
                          anonymous_polls_count, created_at, updated_at)
      SELECT id, 'Discussion', id, group_id, items_count, ranges_string,
             max_depth, newest_first, private, closed_at, closer_id, pinned_at,
             last_activity_at, seen_by_count, members_count, closed_polls_count,
             anonymous_polls_count, created_at, updated_at
      FROM discussions
    SQL

    # Set the sequence past the max discussion id so standalone poll topics get fresh ids
    execute <<~SQL
      SELECT setval('topics_id_seq', (SELECT COALESCE(MAX(id), 0) FROM discussions))
    SQL

    # 3. Create topics for standalone polls (no discussion_id)
    execute <<~SQL
      INSERT INTO topics (topicable_type, topicable_id, group_id, items_count, private,
                          closed_at, last_activity_at, created_at, updated_at)
      SELECT 'Poll', id, group_id, 0, true,
             closed_at, closed_at, created_at, updated_at
      FROM polls
      WHERE discussion_id IS NULL
    SQL

    # 4. discussions.topic_id = discussions.id (just add column with correct value)
    add_column :discussions, :topic_id, :integer
    execute "UPDATE discussions SET topic_id = id"
    add_index :discussions, :topic_id

    # 5. Rename events.discussion_id to topic_id — no data update needed!
    remove_index :events, name: "index_events_on_discussion_id_and_sequence_id"
    remove_index :events, name: "index_events_on_parent_id_and_discussion_id"
    rename_column :events, :discussion_id, :topic_id
    add_index :events, [:topic_id, :sequence_id], unique: true
    add_index :events, [:topic_id]
    add_index :events, [:parent_id, :topic_id], where: "topic_id IS NOT NULL"

    # 6. Rename discussion_readers to topic_readers, rename discussion_id to topic_id
    execute "ALTER TABLE discussion_readers RENAME TO topic_readers"
    execute "ALTER INDEX motion_read_logs_pkey RENAME TO topic_readers_pkey"
    execute "ALTER SEQUENCE discussion_readers_id_seq RENAME TO topic_readers_id_seq"
    remove_index :topic_readers, name: "index_discussion_readers_discussion_id"
    execute 'DROP INDEX IF EXISTS "index_discussion_readers_on_user_id_and_discussion_id"'
    rename_column :topic_readers, :discussion_id, :topic_id
    add_index :topic_readers, [:topic_id, :user_id], unique: true

    # 7. Polls: in-thread polls already have discussion_id = topic_id, standalone need update
    rename_column :polls, :discussion_id, :topic_id
    execute <<~SQL
      UPDATE polls SET topic_id = t.id
      FROM topics t
      WHERE t.topicable_type = 'Poll' AND t.topicable_id = polls.id
        AND polls.topic_id IS NULL
    SQL
    # index_polls_on_discussion_id was auto-renamed to index_polls_on_topic_id by rename_column

    # 8. Remove comments.discussion_id (no longer needed)
    remove_index :comments, name: "index_comments_on_discussion_id"
    remove_column :comments, :discussion_id

    # 9. Remove columns moved to topics
    execute 'DROP INDEX IF EXISTS "index_discussions_on_last_activity_at"'
    remove_column :discussions, :items_count
    remove_column :discussions, :ranges_string
    remove_column :discussions, :max_depth
    remove_column :discussions, :newest_first
    remove_column :discussions, :last_activity_at
    remove_column :discussions, :last_sequence_id
    remove_column :discussions, :first_sequence_id
    remove_column :discussions, :seen_by_count
    remove_column :discussions, :members_count
    remove_column :discussions, :anonymous_polls_count
    remove_column :discussions, :closed_polls_count
    remove_column :discussions, :group_id
    remove_column :discussions, :closed_at
    remove_column :discussions, :closer_id
    remove_column :discussions, :pinned_at
    remove_column :discussions, :private

    remove_column :polls, :group_id

    remove_index :stances, name: :stances_guests, if_exists: true
    remove_column :stances, :volume, :integer, default: 2, null: false
    remove_column :stances, :guest, :boolean, default: false, null: false
    remove_column :stances, :admin, :boolean, null: false, default: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
