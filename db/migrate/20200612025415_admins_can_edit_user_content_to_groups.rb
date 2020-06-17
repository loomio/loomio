class AdminsCanEditUserContentToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :admins_can_edit_user_content, :boolean, null: false, default: false
  end
end
