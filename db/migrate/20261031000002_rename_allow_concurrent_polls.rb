class RenameAllowConcurrentPolls < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '1s'"
    %i[topics discussion_templates].each do |table|
      rename_column table, :allow_concurrent_polls, :polls_one_at_a_time
      execute "UPDATE #{table} SET polls_one_at_a_time = NOT polls_one_at_a_time"
      change_column_default table, :polls_one_at_a_time, false
    end
  end

  def down
    execute "SET LOCAL lock_timeout = '1s'"
    %i[topics discussion_templates].each do |table|
      execute "UPDATE #{table} SET polls_one_at_a_time = NOT polls_one_at_a_time"
      rename_column table, :polls_one_at_a_time, :allow_concurrent_polls
      change_column_default table, :allow_concurrent_polls, false
    end
  end
end
