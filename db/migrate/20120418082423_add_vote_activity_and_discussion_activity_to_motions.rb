class AddVoteActivityAndDiscussionActivityToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :vote_activity, :integer, default: 0
    add_column :motions, :discussion_activity, :integer, default: 0
  end
end
