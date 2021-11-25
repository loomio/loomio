class AddHideResultsToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :hide_results, :integer, null: false, default: 0
  end
end
