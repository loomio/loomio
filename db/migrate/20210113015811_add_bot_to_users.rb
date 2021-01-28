class AddBotToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bot, :boolean, default: false, null: false
    change_column :users, :email, :citext, null: true, default: nil
  end
end
