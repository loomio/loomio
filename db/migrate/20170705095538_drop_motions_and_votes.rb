class DropMotionsAndVotes < ActiveRecord::Migration
  def change
    drop_table :motions
    drop_table :votes
    drop_table :motion_readers
    remove_column :discussions, :motions_count
    remove_column :discussions, :closed_motions_count
    remove_column :groups, :motions_count
    drop_table :networks
    drop_table :network_coordinators
    drop_table :network_membership_requests
    drop_table :network_memberships
    remove_column :polls, :motion_id
    drop_table :did_not_votes
    drop_table :group_requests
    drop_table :blog_stories
    drop_table :categories
  end
end
