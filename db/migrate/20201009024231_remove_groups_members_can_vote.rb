class RemoveGroupsMembersCanVote < ActiveRecord::Migration[5.2]
  def change
    remove_column :groups, :members_can_vote
  end
end
