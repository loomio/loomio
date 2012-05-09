class RemoveNoVoteCountFromMotion < ActiveRecord::Migration
  def up
    remove_column :motions, :no_vote_count
  end

  def down
    add_column :motions, :no_vote_count, :integer
  end
end
