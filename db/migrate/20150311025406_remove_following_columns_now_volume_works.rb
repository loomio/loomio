class RemoveFollowingColumnsNowVolumeWorks < ActiveRecord::Migration
  def change
    remove_column :memberships, :following_by_default, :boolean
    remove_column :memberships, :email_new_discussions_and_proposals
    remove_column :users, :email_new_discussions_and_proposals
    remove_column :discussion_readers, :following, :boolean
    remove_column :users, :email_followed_threads
  end
end
