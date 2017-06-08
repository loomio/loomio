class AddFbCommunityIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :facebook_community_id, :integer, null: true
  end
end
