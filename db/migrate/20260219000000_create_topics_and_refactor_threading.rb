class CreateTopicsAndRefactorThreading < ActiveRecord::Migration[7.0]
  def up
    # 1. Create topics table
    create_table :topics do |t|
      t.string  :topicable_type, null: false
      t.integer :topicable_id,   null: false
      t.integer :items_count,    default: 0, null: false
      t.string  :ranges_string
      t.integer :max_depth,      default: 2, null: false
      t.boolean :newest_first,   default: false, null: false
      t.datetime :last_activity_at, precision: nil
      t.timestamps
    end
    add_index :topics, [:topicable_type, :topicable_id], unique: true

    # 2. Backfill topics from discussions
    execute <<~SQL
      INSERT INTO topics (topicable_type, topicable_id, items_count, ranges_string, max_depth, newest_first, last_activity_at, created_at, updated_at)
      SELECT 'Discussion', id, items_count, ranges_string, max_depth, newest_first, last_activity_at, created_at, updated_at
      FROM discussions
    SQL

    # 3. Add topic_id to events and backfill
    add_column :events, :topic_id, :integer
    execute <<~SQL
      UPDATE events SET topic_id = (
        SELECT t.id FROM topics t
        WHERE t.topicable_type = 'Discussion'
        AND t.topicable_id = events.discussion_id
      )
      WHERE discussion_id IS NOT NULL
    SQL

    # 4. Drop old indexes on discussion_id from events
    remove_index :events, name: "index_events_on_discussion_id_and_sequence_id"
    remove_index :events, name: "index_events_on_parent_id_and_discussion_id"

    # 5. Remove discussion_id from events
    remove_column :events, :discussion_id

    # 6. Add new indexes on topic_id for events
    add_index :events, [:topic_id, :sequence_id], unique: true
    add_index :events, [:topic_id]
    add_index :events, [:parent_id, :topic_id], where: "topic_id IS NOT NULL"

    # 7. Remove discussion_id from comments
    remove_index :comments, name: "index_comments_on_discussion_id"
    remove_column :comments, :discussion_id

    # 8. Transform discussion_readers to topic_readers
    rename_table :discussion_readers, :topic_readers
    add_column :topic_readers, :topic_id, :integer

    # Backfill topic_id on topic_readers from discussions→topics mapping
    execute <<~SQL
      UPDATE topic_readers SET topic_id = (
        SELECT t.id FROM topics t
        WHERE t.topicable_type = 'Discussion'
        AND t.topicable_id = topic_readers.discussion_id
      )
    SQL

    # Remove old indexes (use execute for unique index to avoid Rails constraint detection issues after rename)
    remove_index :topic_readers, name: "index_discussion_readers_discussion_id"
    execute 'DROP INDEX IF EXISTS "index_discussion_readers_on_user_id_and_discussion_id"'

    # Remove discussion_id column
    remove_column :topic_readers, :discussion_id

    # Add new indexes
    add_index :topic_readers, [:user_id, :topic_id], unique: true
    add_index :topic_readers, [:topic_id]

    # 9. Remove moved columns from discussions
    # Remove index before column (column removal auto-drops indexes, but be explicit)
    execute 'DROP INDEX IF EXISTS "index_discussions_on_last_activity_at"'
    remove_column :discussions, :items_count
    remove_column :discussions, :ranges_string
    remove_column :discussions, :max_depth
    remove_column :discussions, :newest_first
    remove_column :discussions, :last_activity_at
    remove_column :discussions, :last_sequence_id
    remove_column :discussions, :first_sequence_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
