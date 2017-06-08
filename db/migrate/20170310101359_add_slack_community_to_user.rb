class AddSlackCommunityToUser < ActiveRecord::Migration
  def change
    add_column :users, :slack_community_id, :integer, null: true
  end
end
