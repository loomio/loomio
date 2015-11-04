class AddAdminCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :admin_memberships_count, :integer, default: 0, null: false
  end
end
