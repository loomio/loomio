class AddStancesCountToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :stances_count, :integer, default: 0, null: false
  end
end
