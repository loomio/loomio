class RemoveAdminFromStances < ActiveRecord::Migration[7.2]
  def change
    remove_column :stances, :admin, :boolean, null: false, default: false
  end
end
