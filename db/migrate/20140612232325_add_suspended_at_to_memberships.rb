class AddSuspendedAtToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :is_suspended, :boolean, null: false, default: false
  end
end
