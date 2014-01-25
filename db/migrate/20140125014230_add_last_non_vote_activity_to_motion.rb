class AddLastNonVoteActivityToMotion < ActiveRecord::Migration
  def change
    add_column :motions, :last_non_vote_activity_at, :datetime
  end
end
