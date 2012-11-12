class AddLastVoteAtToMotions < ActiveRecord::Migration
 def up
    add_column :motions, :last_vote_at, :datetime
    remove_column :motions, :activity
  end

  def down
    remove_column :motions, :last_vote_at
    add_column :motions, :activity, :integer, :default => 0
  end
end
