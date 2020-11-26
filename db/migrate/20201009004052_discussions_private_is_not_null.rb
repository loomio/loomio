class DiscussionsPrivateIsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :discussions, :private, :boolean, default: true, null: false
  end
end
