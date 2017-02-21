class AddCounterToGroups < ActiveRecord::Migration
  def change
    add_column :discussions, :closed_polls_count, :integer, null: false, default: 0
    add_column :groups, :closed_polls_count, :integer, null: false, default: 0
  end
end
