class AddPollVersionCounterCache < ActiveRecord::Migration[5.1]
  def change
    add_column :polls, :versions_count, :integer, default: 0
  end
end
