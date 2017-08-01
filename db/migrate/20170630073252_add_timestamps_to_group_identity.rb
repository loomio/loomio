class AddTimestampsToGroupIdentity < ActiveRecord::Migration
  def change
    add_column :group_identities, :created_at, :datetime, null: false
    add_column :group_identities, :updated_at, :datetime, null: false
  end
end
