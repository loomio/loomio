class AddShowNoneOfTheAboveToPolls < ActiveRecord::Migration[7.0]
  def change
    add_column :polls, :show_none_of_the_above, :boolean, default: false, null: false
    add_column :polls, :none_of_the_above_count, :integer, default: 0, null: false
    add_column :stances, :none_of_the_above, :boolean, default: false, null: false
  end
end
