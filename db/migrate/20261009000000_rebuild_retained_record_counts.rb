require_relative 'support/retained_record_count_rebuild'

class RebuildRetainedRecordCounts < ActiveRecord::Migration[8.1]
  def up
    # Hold writers until the baseline is rebuilt. Otherwise an old snapshot
    # could overwrite a count that a concurrent transaction has just changed.
    execute 'LOCK TABLE groups, users, memberships, topics, polls, discussions, poll_templates, topic_readers, topic_items, comments, outcomes, versions IN SHARE ROW EXCLUSIVE MODE'
    RetainedRecordCountRebuild.run(connection)
    remove_columns :groups, :closed_polls_count, :delegates_count, :discussion_templates_count, :subgroups_count
    remove_columns :topics, :anonymous_polls_count, :closed_polls_count, :members_count
    remove_column :tags, :taggings_count
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Retired counters are no longer maintained'
  end
end
