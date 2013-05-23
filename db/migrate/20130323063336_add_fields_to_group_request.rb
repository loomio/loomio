class AddFieldsToGroupRequest < ActiveRecord::Migration
  def change
    add_column :group_requests, :high_touch, :boolean, default: false, null: false
    add_column :group_requests, :approved_at, :datetime
    add_column :group_requests, :defered_until, :datetime
  end
end
