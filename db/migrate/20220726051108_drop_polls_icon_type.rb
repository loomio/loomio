class DropPollsIconType < ActiveRecord::Migration[6.1]
  def change
    remove_column :polls, :icon_type
  end
end
