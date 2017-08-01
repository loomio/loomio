class AddLowercaseIndexOnGroupsSubdomain < ActiveRecord::Migration
  def change
    enable_extension :citext
    Group.where(subdomain: '').update_all(subdomain: nil)
    change_column :groups, :subdomain, :citext
    add_index :groups, :subdomain, unique: true
  end
end
