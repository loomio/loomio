class AddHasReadSystemNoticeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_read_system_notice, :boolean, :default => false,
      :null => false
  end
end
