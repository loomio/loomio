class AddPollsOneAtATime < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '1s'"
    %i[topics discussion_templates].each do |table|
      # NULL marks legacy rows without rewriting them under a schema lock.
      # Setting the default separately affects only records created afterward.
      add_column table, :polls_one_at_a_time, :boolean
      change_column_default table, :polls_one_at_a_time, from: nil, to: false
    end
    BackfillPollSequenceWorker.set(wait: 10.minutes).perform_later
  end

  def down
    execute "SET LOCAL lock_timeout = '1s'"
    %i[topics discussion_templates].each do |table|
      remove_column table, :polls_one_at_a_time
    end
  end
end
