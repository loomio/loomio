class AddColumnsToGroupIdentities < ActiveRecord::Migration
  def change
    add_column :group_identities, :channel_name, :string
    add_column :group_identities, :channel_id, :string
  end
end
