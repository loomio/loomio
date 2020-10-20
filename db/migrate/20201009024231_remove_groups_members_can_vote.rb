class RemoveGroupsMembersCanVote < ActiveRecord::Migration[5.2]
  def change
    # actually remove after 2020-11-01
    # remove_column :groups, :members_can_vote
  end
end
