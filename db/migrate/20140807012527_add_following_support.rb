class AddFollowingSupport < ActiveRecord::Migration
  def change
    add_column    :memberships, :following_by_default, :boolean, default: false, null: false
    remove_column :discussion_readers, :following
    remove_column :motion_readers, :following
    add_column    :discussion_readers, :following, :boolean, default: nil
  end
end
