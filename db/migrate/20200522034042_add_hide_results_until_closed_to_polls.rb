class AddHideResultsUntilClosedToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :hide_results_until_closed, :boolean, default: false, null: false
  end
end
