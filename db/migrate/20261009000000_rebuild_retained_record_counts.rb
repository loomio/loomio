require_relative 'support/retained_record_count_rebuild'

class RebuildRetainedRecordCounts < ActiveRecord::Migration[8.1]
  def up
    # Hold writers until the baseline is rebuilt. Otherwise an old snapshot
    # could overwrite a count that a concurrent transaction has just changed.
    execute 'LOCK TABLE groups, users, memberships, topics, polls, discussions, poll_templates, topic_readers, topic_items, comments, outcomes, versions IN SHARE ROW EXCLUSIVE MODE'
    RetainedRecordCountRebuild.run(connection)
  end

  def down
    # Counts remain valid when rolling back the application. Keep the retired
    # columns too, so deploying this refactor needs no destructive DDL.
  end
end
