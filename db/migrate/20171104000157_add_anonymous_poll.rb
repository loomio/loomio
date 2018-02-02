class AddAnonymousPoll < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :anonymous, :boolean, default: false, null: false
  end
end
