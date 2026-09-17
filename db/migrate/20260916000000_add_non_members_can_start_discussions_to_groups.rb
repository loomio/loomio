class AddNonMembersCanStartDiscussionsToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :non_members_can_start_discussions, :boolean, default: false, null: false
  end
end
