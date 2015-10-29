class AngularByDefault < ActiveRecord::Migration
  def change
    change_column :users, :angular_ui_enabled, :boolean, default: true, null: false
  end
end
