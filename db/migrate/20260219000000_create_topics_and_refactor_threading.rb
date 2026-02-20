class CreateTopicsAndRefactorThreading < ActiveRecord::Migration[7.0]
  def up
    # 1. Create topics table with all columns
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
      t.integer :anonymous_polls_count, default: 0, null: false
      t.timestamps
    end
    add_index :topics, [:topicable_type, :topicable_id], unique: true
    add_index :topics, :group_id

    # 2. Backfill topics from discussions
    execute <<~SQL
      INSERT INTO topics (topicable_type, topicable_id, group_id, items_count, ranges_string,
                          max_depth, newest_first, private, closed_at, closer_id, pinned_at,
                          last_activity_at, seen_by_count, members_count, anonymous_polls_count, created_at, updated_at)
      SELECT 'Discussion', id, group_id, items_count, ranges_string,
             max_depth, newest_first, private, closed_at, closer_id, pinned_at,
             last_activity_at, seen_by_count, members_count, anonymous_polls_count, created_at, updated_at
      FROM discussions
    SQL

    # 3. Add topic_id to discussions and polls, backfill
    add_column :discussions, :topic_id, :integer
    add_column :polls, :topic_id, :integer

    execute <<~SQL
      UPDATE discussions SET topic_id = t.id
      FROM topics t
      WHERE t.topicable_type = 'Discussion' AND t.topicable_id = discussions.id
    SQL

    execute <<~SQL
      UPDATE polls SET topic_id = t.id
      FROM topics t
      WHERE t.topicable_type = 'Poll' AND t.topicable_id = polls.id
    SQL

    execute <<~SQL
      UPDATE polls SET topic_id = d.topic_id
      FROM discussions d
      WHERE d.id = polls.discussion_id AND polls.topic_id IS NULL
    SQL

    add_index :discussions, :topic_id
    add_index :polls, :topic_id

    # 4. Add topic_id to events and backfill
    add_column :events, :topic_id, :integer
    execute <<~SQL
      UPDATE events SET topic_id = (
        SELECT t.id FROM topics t
        WHERE t.topicable_type = 'Discussion'
        AND t.topicable_id = events.discussion_id
      )
      WHERE discussion_id IS NOT NULL
    SQL

    # 5. Drop old indexes on discussion_id from events, add new ones on topic_id
    remove_index :events, name: "index_events_on_discussion_id_and_sequence_id"
    remove_index :events, name: "index_events_on_parent_id_and_discussion_id"
    add_index :events, [:topic_id, :sequence_id], unique: true
    add_index :events, [:topic_id]
    add_index :events, [:parent_id, :topic_id], where: "topic_id IS NOT NULL"

    # 6. Transform discussion_readers to topic_readers
    rename_table :discussion_readers, :topic_readers
    add_column :topic_readers, :topic_id, :integer

    execute <<~SQL
      UPDATE topic_readers SET topic_id = (
        SELECT t.id FROM topics t
        WHERE t.topicable_type = 'Discussion'
        AND t.topicable_id = topic_readers.discussion_id
      )
    SQL

    remove_index :topic_readers, name: "index_discussion_readers_discussion_id"
    execute 'DROP INDEX IF EXISTS "index_discussion_readers_on_user_id_and_discussion_id"'

    add_index :topic_readers, [:topic_id, :user_id], unique: true

    # TODO before deploy, move this to a new migration, not to be run until ready.
    remove_column :events, :discussion_id
    remove_index :comments, name: "index_comments_on_discussion_id"
    remove_column :comments, :discussion_id
    remove_column :topic_readers, :discussion_id

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
    remove_column :polls, :discussion_id

    remove_index :stances, name: :stances_guests, if_exists: true
    remove_column :stances, :volume, :integer, default: 2, null: false
    remove_column :stances, :guest, :boolean, default: false, null: false
    remove_column :stances, :admin, :boolean, null: false, default: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
