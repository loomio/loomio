class AddPreviousVoteIdToVotes < ActiveRecord::Migration
  def up
    add_column :votes, :previous_vote_id, :integer
  end
  
  def down
    remove_column :votes, :previous_vote_id
  end
end
