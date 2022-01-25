class AddHideResultsToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :hide_results, :integer, default: 0, null: false
    Poll.where(hide_results_until_closed: true).update_all(hide_results: 'until_closed')
  end
end
