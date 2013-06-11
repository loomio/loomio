class AddAdminNotesToGroupRequests < ActiveRecord::Migration
  def up
    add_column :group_requests, :admin_notes, :text
  end

  def down
    remove_column :group_requests, :admin_notes
  end
end
