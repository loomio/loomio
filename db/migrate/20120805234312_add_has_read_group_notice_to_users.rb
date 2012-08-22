class AddHasReadGroupNoticeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_read_group_notice, :boolean, :default => false,
      :null => false
  end
end
