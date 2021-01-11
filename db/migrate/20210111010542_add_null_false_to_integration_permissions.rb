class AddNullFalseToIntegrationPermissions < ActiveRecord::Migration[5.2]
  def up
    change_column :integrations, :permissions, :string, null: false, array: true, default: []
  end

  def down
    change_column :integrations, :permissions, :string, array: true
  end
end
