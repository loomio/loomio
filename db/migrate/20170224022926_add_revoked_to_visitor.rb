class AddRevokedToVisitor < ActiveRecord::Migration
  def change
    add_column :visitors, :revoked, :boolean, default: false, null: false
  end
end
