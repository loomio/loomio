class AddAngularUiEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :angular_ui_enabled, :boolean, default: false, null: false
  end
end
