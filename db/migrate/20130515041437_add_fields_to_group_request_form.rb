class AddFieldsToGroupRequestForm < ActiveRecord::Migration
  def up
    add_column :group_requests, :why_do_you_want, :text
    add_column :group_requests, :group_core_purpose, :text
  end

  def down
    remove_column :group_requests, :group_core_purpose
    remove_column :group_requests, :why_do_you_want
  end
end
