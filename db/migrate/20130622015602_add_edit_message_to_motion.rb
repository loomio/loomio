class AddEditMessageToMotion < ActiveRecord::Migration
  def change
    add_column :motions, :edit_message, :text
  end
end
