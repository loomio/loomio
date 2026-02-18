class UsersAutotranslateOffByDefault < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :auto_translate, :boolean, default: false, null: false
    User.update_all(auto_translate: false)
  end
end
