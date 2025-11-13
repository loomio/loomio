class AddAutoTranslateToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :auto_translate, :boolean, default: true, null: false
  end
end
