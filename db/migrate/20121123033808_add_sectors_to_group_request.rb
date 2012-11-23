class AddSectorsToGroupRequest < ActiveRecord::Migration
  def change
    add_column :group_requests, :sectors, :string
  end
end
