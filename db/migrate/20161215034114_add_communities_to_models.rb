class AddCommunitiesToModels < ActiveRecord::Migration
  def change
    add_column :groups, :community_id, :integer
    add_column :discussions, :community_id, :integer
  end
end
