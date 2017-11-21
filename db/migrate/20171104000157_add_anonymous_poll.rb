class AddAnonymousPoll < ActiveRecord::Migration
  def change
    add_column :polls, :anonymous, :boolean, default: false, null: false
  end
end
