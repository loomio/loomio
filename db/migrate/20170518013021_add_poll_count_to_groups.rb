class AddPollCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :polls_count, :integer, default: 0, null: false
  end
end
