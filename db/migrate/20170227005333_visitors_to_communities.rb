class VisitorsToCommunities < ActiveRecord::Migration
  def change
    rename_column :visitors, :poll_id, :community_id
  end
end
